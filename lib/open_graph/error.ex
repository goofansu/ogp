defmodule OpenGraph.Error do
  @moduledoc false

  defexception [:reason]

  @impl true
  def message(%__MODULE__{reason: reason}) do
    format_reason(reason)
  end

  defp format_reason({:redirect_failed, status}) do
    "redirect failed. status: #{status}"
  end

  defp format_reason({:response_unexpected, status}) do
    "response unexpected. status: #{status}"
  end

  defp format_reason({:request_failed, reason}) do
    "request failed. reason: #{reason}"
  end
end
