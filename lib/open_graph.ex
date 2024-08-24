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

  @type url() :: URI.t() | String.t()
  @type value() :: String.t() | nil

  @type t() :: %__MODULE__{
          title: value(),
          type: value(),
          image: value(),
          url: value(),
          audio: value(),
          description: value(),
          determiner: value(),
          locale: value(),
          site_name: value(),
          video: value()
        }

  @doc """
  Fetch URL and parse Open Graph protocol.

  Returns `{:ok, %OpenGraph{}}` for succussful request, otherwise, returns `{:error, %OpenGraph.Error{}}`.
  """

  @spec fetch(url(), req_options :: keyword()) ::
          {:ok, OpenGraph.t()} | {:error, OpenGraph.Error.t()}
  def fetch(url, req_options \\ []) do
    options = Keyword.merge(req_options, Application.get_env(:ogp, :req_options, []))

    case Req.get(url, options) do
      {:ok, %Req.Response{status: status} = response} when status in 200..299 ->
        {:ok, parse(response.body)}

      {:ok, %Req.Response{status: status}} when status in 300..399 ->
        {:error,
         %OpenGraph.Error{
           reason: {:missing_redirect_location, status}
         }}

      {:ok, %Req.Response{status: status}} ->
        {:error,
         %OpenGraph.Error{
           reason: {:unexpected_status_code, status}
         }}

      {:error, error} ->
        {:error,
         %OpenGraph.Error{
           reason: {:request_error, Exception.message(error)}
         }}
    end
  end

  @doc """
  Similar to `fetch/2` but raises an `OpenGraph.Error` if request failed.

  Returns `%OpenGraph{}`.
  """
  @spec fetch!(url(), req_options :: keyword()) :: OpenGraph.t()
  def fetch!(url, req_options \\ []) do
    case fetch(url, req_options) do
      {:ok, result} ->
        result

      {:error, error} ->
        raise error
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
