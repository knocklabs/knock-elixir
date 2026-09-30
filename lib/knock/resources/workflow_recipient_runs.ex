defmodule Knock.WorkflowRecipientRuns do
  @moduledoc """
  Knock resources for accessing workflow recipient runs
  """
  alias Knock.Api
  alias Knock.Client

  @doc """
  Returns paginated workflow recipient runs for the environment.

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:workflow` - workflow key to filter runs with
  * `:status` - list of statuses to filter runs with (`queued`, `processing`, `paused`,
    `completed`, `cancelled`)
  * `:tenant` - tenant id to filter runs with
  * `:has_errors` - only return runs that have (or don't have) errors
  * `:recipient` - user id or `%{id: id, collection: collection}` object reference to filter
    runs with
  * `:starting_at` - only return runs started after the given ISO-8601 timestamp
  * `:ending_at` - only return runs started before the given ISO-8601 timestamp
  """
  @spec list(Client.t(), Keyword.t()) :: Api.response()
  def list(client, options \\ []) do
    Api.get(client, "/workflow_recipient_runs", query: options)
  end

  @doc """
  Returns the workflow recipient run with the given id.
  """
  @spec get(Client.t(), String.t()) :: Api.response()
  def get(client, id) do
    Api.get(client, "/workflow_recipient_runs/#{id}")
  end
end
