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

  @doc """
  Creates schedule instances for the specified recipients on the properties map.

  Expected properties:
  - recipients: list of recipients for schedules to be created for
  - actor: actor to be used when trigger the target workflow
  - repeats: repeat rules to specify when the workflow must be triggered
  - data: data to be used as variables when the workflow runs
  - tenant: tenant to be used for when the workflow runs
  """
  @spec create_schedules(Knock.Client.t(), String.t(), map()) :: Api.response()
  def create_schedules(client, key, properties \\ %{}) do
    attrs = Map.put(properties, :workflow, key)
    Api.post(client, "/schedules", attrs)
  end

  @doc """
  Updates schedule instances with argument properties.

  Expected properties:
  - actor: actor to be used when trigger the target workflow
  - repeats: repeat rules to specify when the workflow must be triggered
  - data: data to be used as variables when the workflow runs
  - tenant: tenant to be used for when the workflow runs
  """
  @spec update_schedules(Knock.Client.t(), [String.t()], map()) :: Api.response()
  def update_schedules(client, schedule_ids, properties \\ %{}) do
    attrs = Map.put(properties, :schedule_ids, schedule_ids)
    Api.put(client, "/schedules", attrs)
  end

  @doc """
  Returns paginated schedules for the provided environment

  # Available optional parameters:
  #
  # - page_size: specify size of the page to be returned by the api. (max limit: 50)
  # - after:  after cursor for pagination
  # - before: before cursor for pagination
  # - tenant: tenant_id to filter schedues with
  # - recipients: list of recipients to filter schedules with

  """
  @spec list_schedules(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def list_schedules(client, key, options \\ []) do
    options = Keyword.put(options, :workflow, key)
    Api.get(client, "/schedules", query: options)
  end

  @doc """
  Delete schedule instances.
  """
  @spec delete_schedules(Knock.Client.t(), [String.t()]) :: Api.response()
  def delete_schedules(client, schedule_ids) do
    Api.delete(client, "/schedules", body: %{schedule_ids: schedule_ids})
  end

  @doc """
  Creates schedule instances in bulk.

  Accepts a list of schedules and creates them asynchronously.
  The endpoint returns a BulkOperation.

  Each schedule in the list should contain:
  - recipient: recipient for the schedule to be created for
  - actor: actor to be used when trigger the target workflow
  - repeats: repeat rules to specify when the workflow must be triggered
  - data: data to be used as variables when the workflow runs
  - tenant: tenant to be used for when the workflow runs
  - scheduled_at: ISO-8601 formatted date time for when the schedule should start
  - ending_at: ISO-8601 formatted date time for when the schedule should end
  """
  @spec bulk_create_schedules(Knock.Client.t(), [map()]) :: Api.response()
  def bulk_create_schedules(client, schedules) do
    Api.post(client, "/schedules/bulk/create", %{schedules: schedules})
  end
end
