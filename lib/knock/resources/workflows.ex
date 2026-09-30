defmodule Knock.Workflows do
  @moduledoc """
  Functions for interacting with Knock notify resources.
  """
  alias Knock.Api
  alias Knock.Client
  alias Knock.Schedules

  @doc """
  Executes a notify call for the workflow with the given key.

  Note: properties must contain at least `recipents` for the call to be valid.

  Options can include:
  * `idempotency_key`: A unique key to prevent duplicate requests
  """
  @spec trigger(Client.t(), String.t(), map(), keyword()) :: Api.response()
  def trigger(client, key, properties, options \\ []) do
    Api.post(client, "/workflows/#{key}/trigger", properties, options)
  end

  @doc """
  Cancels the workflow with the given cancellation key.

  Can optionally be provided with:

  - `recipients`: A list of recipients to cancel the notify for
  """
  @spec cancel(Client.t(), String.t(), String.t(), map()) :: Api.response()
  def cancel(client, key, cancellation_key, properties \\ %{}) do
    attrs = Map.put(properties, "cancellation_key", cancellation_key)
    Api.post(client, "/workflows/#{key}/cancel", attrs)
  end

  @doc """
  Creates schedule instances for the specified recipients on the properties map.
  See `Knock.Schedules.create/2`.
  """
  @spec create_schedules(Client.t(), String.t(), map()) :: Api.response()
  def create_schedules(client, key, properties \\ %{}) do
    Schedules.create(client, Map.put(properties, :workflow, key))
  end

  @doc """
  Updates schedule instances with argument properties. See `Knock.Schedules.update/3`.
  """
  @spec update_schedules(Client.t(), [String.t()], map()) :: Api.response()
  def update_schedules(client, schedule_ids, properties \\ %{}) do
    Schedules.update(client, schedule_ids, properties)
  end

  @doc """
  Returns paginated schedules for the given workflow. See `Knock.Schedules.list/3` for the
  available optional parameters.
  """
  @spec list_schedules(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def list_schedules(client, key, options \\ []) do
    Schedules.list(client, key, options)
  end

  @doc """
  Delete schedule instances. See `Knock.Schedules.delete/2`.
  """
  @spec delete_schedules(Client.t(), [String.t()]) :: Api.response()
  def delete_schedules(client, schedule_ids) do
    Schedules.delete(client, schedule_ids)
  end

  @doc """
  Creates schedule instances in bulk. See `Knock.Schedules.bulk_create/2`.
  """
  @spec bulk_create_schedules(Client.t(), [map()]) :: Api.response()
  def bulk_create_schedules(client, schedules) do
    Schedules.bulk_create(client, schedules)
  end
end
