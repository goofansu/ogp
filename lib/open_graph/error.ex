defmodule OpenGraph.Error do
  defexception [:reason]

  @type status_code() :: integer()

  @type reason() ::
          {:missing_redirect_location, status_code()}
          | {:unexpected_status_code, status_code()}
          | {:request_error, String.t()}

  @type t() :: %__MODULE__{reason: reason()}

  @impl true
  def message(%__MODULE__{reason: reason}) do
    format_reason(reason)
  end

  defp format_reason({:missing_redirect_location, status_code}) do
    "redirect response is received but location not found in HTTP headers. HTTP status code: #{status_code}"
  end

  defp format_reason({:unexpected_status_code, status_code}) do
    "unexpected response is received. HTTP status code: #{status_code}"
  end

  defp format_reason({:request_error, reason}) do
    "request error. reason: #{reason}"
  end
end
