defmodule OpenGraph do
  defstruct [
    # Basic Metadata
    :title,
    :type,
    :image,
    :url,
    # Optional Metadata
    :audio,
    :description,
    :determiner,
    :locale,
    :site_name,
    :video
  ]

  @spec fetch(String) :: __MODULE__
  def fetch(url) do
    case Finch.build(:get, url) |> Finch.request(OpenGraphFinch) do
      {:ok, %Finch.Response{status: status} = response} when status in [301, 302] ->
        # Follow redirect
        {"location", location} = List.keyfind(response.headers, "location", 0)
        fetch(location)

      {:ok, %Finch.Response{status: 200} = response} ->
        parse(response.body)

      _ ->
        %__MODULE__{}
    end
  end

  @spec parse(String) :: __MODULE__
  def parse(html) do
    {:ok, document} = Floki.parse_document(html)
    og_elements = Floki.find(document, "meta[property^='og:'][content]")
    properties = Floki.attribute(og_elements, "property")
    contents = Floki.attribute(og_elements, "content")

    fields =
      [properties, contents]
      |> List.zip()
      |> Enum.reduce(%{}, &put_field/2)

    struct(__MODULE__, fields)
  end

  defp put_field({"og:" <> property, content}, acc) do
    Map.put_new(acc, String.to_existing_atom(property), content)
  rescue
    ArgumentError ->
      acc
  end
end
