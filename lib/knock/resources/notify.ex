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
end
