defmodule Knock.Schedules do
  @moduledoc """
  Knock resources for accessing schedules
  """
  alias Knock.Api
  alias Knock.Client

  @doc """
  Creates schedule instances for the recipients given.

  Expected properties:
  - workflow: key of the workflow to trigger
  - recipients: list of recipients for schedules to be created for
  - repeats: repeat rules to specify when the workflow must be triggered
  - actor (optional): actor to be used when triggering the target workflow
  - data (optional): data to be used as variables when the workflow runs
  - tenant (optional): tenant to be used for when the workflow runs
  - scheduled_at (optional): ISO-8601 date time for when the schedule should start
  - ending_at (optional): ISO-8601 date time for when the schedule should end
  """
  @spec create(Client.t(), map()) :: Api.response()
  def create(client, params) do
    Api.post(client, "/schedules", params)
  end

  @doc """
  Updates the schedule instances given with the properties provided.

  Expected properties:
  - actor: actor to be used when triggering the target workflow
  - repeats: repeat rules to specify when the workflow must be triggered
  - data: data to be used as variables when the workflow runs
  - tenant: tenant to be used for when the workflow runs
  - scheduled_at: ISO-8601 date time for when the schedule should start
  - ending_at: ISO-8601 date time for when the schedule should end
  """
  @spec update(Client.t(), [String.t()], map()) :: Api.response()
  def update(client, schedule_ids, params \\ %{}) do
    Api.put(client, "/schedules", Map.put(params, :schedule_ids, schedule_ids))
  end

  @doc """
  Returns paginated schedules for the given workflow.

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:tenant` - tenant id to filter schedules with
  * `:recipients` - list of recipients (user ids or `%{id: id, collection: collection}` object
    references) to filter schedules with
  """
  @spec list(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def list(client, workflow, options \\ []) do
    Api.get(client, "/schedules", query: Keyword.put(options, :workflow, workflow))
  end

  @doc """
  Deletes the schedule instances given.
  """
  @spec delete(Client.t(), [String.t()]) :: Api.response()
  def delete(client, schedule_ids) do
    Api.delete(client, "/schedules", body: %{schedule_ids: schedule_ids})
  end

  @doc """
  Creates schedule instances in bulk. Returns a bulk operation.

  Each schedule in the list should contain:
  - workflow: key of the workflow to trigger
  - recipient: recipient for the schedule to be created for
  - repeats: repeat rules to specify when the workflow must be triggered
  - actor (optional): actor to be used when triggering the target workflow
  - data (optional): data to be used as variables when the workflow runs
  - tenant (optional): tenant to be used for when the workflow runs
  - scheduled_at (optional): ISO-8601 date time for when the schedule should start
  - ending_at (optional): ISO-8601 date time for when the schedule should end
  """
  @spec bulk_create(Client.t(), [map()]) :: Api.response()
  def bulk_create(client, schedules) do
    Api.post(client, "/schedules/bulk/create", %{schedules: schedules})
  end
end
