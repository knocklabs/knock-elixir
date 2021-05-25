defmodule Knock.Notify do
  @moduledoc """
  Functions for interacting with Knock notify resources.
  """
  alias Knock.Api

  @doc """
  Executes a notify call for the notification workflow with the given key. Note: properties
  must contain at least `actor` and `recipents` for the call to be valid.
  """
  @spec notify(Knock.Client.t(), String.t(), map()) :: Api.response()
  def notify(client, key, properties) do
    attrs = Map.put(properties, "name", key)

    Api.post(client, "/notify", attrs)
  end

  @doc """
  Cancels the given notify call fr the workflow with the given key and cancelation key.

  Can optionally be provided with:

  - `recipients`: A list of user ids to cancel the notify for
  """
  @spec cancel(Knock.Client.t(), String.t(), String.t(), map()) :: Api.response()
  def cancel(client, workflow_key, cancelation_key, properties \\ %{}) do
    attrs =
      properties
      |> Map.put("name", workflow_key)
      |> Map.put("cancelation_key", cancelation_key)

    Api.post(client, "/notify/cancel", attrs)
  end
end
