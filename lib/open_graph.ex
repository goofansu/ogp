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

  @type value :: String.t() | nil

  @type t :: %__MODULE__{
          title: value,
          type: value,
          image: value,
          url: value,
          audio: value,
          description: value,
          determiner: value,
          locale: value,
          site_name: value,
          video: value
        }

  @doc """
  Fetch URL and parse Open Graph protocol.

  Returns `{:ok, %OpenGraph{}}` for succussful request, otherwise, returns `{:error, reason}`.
  """
  @type reason ::
          {:redirect_failed, integer}
          | {:response_unexpected, integer}
          | {:request_failed, String.t()}

  @spec fetch(String.t()) :: {:ok, OpenGraph.t()} | {:error, reason}
  def fetch(url) do
    case Finch.build(:get, url) |> Finch.request(OpenGraphFinch) do
      {:ok, %Finch.Response{status: status} = response} when status in 200..299 ->
        {:ok, parse(response.body)}

      {:ok, %Finch.Response{status: status} = response} when status in 300..399 ->
        case List.keyfind(response.headers, "location", 0) do
          {_, location} ->
            fetch(location)

          nil ->
            {:error, {:redirect_failed, response.status}}
        end

      {:ok, response} ->
        {:error, {:response_unexpected, response.status}}

      {:error, %{reason: reason}} ->
        {:error, {:request_failed, reason}}
    end
  end

  @doc """
  Similar to `fetch/1` but raises a `OpenGraph.Error` exception if request failed.

  Returns `%OpenGraph{}`.
  """
  @spec fetch!(String.t()) :: OpenGraph.t()
  def fetch!(url) do
    case fetch(url) do
      {:ok, result} ->
        result

      {:error, reason} ->
        raise OpenGraph.Error, reason: reason
    end
  end

  @doc """
  Parse Open Graph protocol.

  Returns `%OpenGraph{}`.

  ## Examples

      iex> OpenGraph.parse("<meta property='og:title' content='GitHub' />")
      %OpenGraph{title: "GitHub"}
  """
  @spec parse(String.t()) :: OpenGraph.t()
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
