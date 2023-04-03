defmodule Knock.Workflows do
  @moduledoc """
  Functions for interacting with Knock notify resources.
  """
  alias Knock.Api

  @doc """
  Executes a notify call for the workflow with the given key.

  Note: properties must contain at least `recipents` for the call to be valid.

  Options can include:
  * `idempotency_key`: A unique key to prevent duplicate requests
  """
  @spec trigger(Knock.Client.t(), String.t(), map(), keyword()) :: Api.response()
  def trigger(client, key, properties, options \\ []) do
    Api.post(client, "/workflows/#{key}/trigger", properties, options)
  end

  @doc """
  Cancels the workflow with the given cancellation key.

  Can optionally be provided with:

  - `recipients`: A list of recipients to cancel the notify for
  """
  @spec cancel(Knock.Client.t(), String.t(), String.t(), map()) :: Api.response()
  def cancel(client, key, cancellation_key, properties \\ %{}) do
    attrs = Map.put(properties, "cancellation_key", cancellation_key)
    Api.post(client, "/workflows/#{key}/cancel", attrs)
  end
end
