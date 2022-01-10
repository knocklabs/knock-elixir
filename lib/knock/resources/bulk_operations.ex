defmodule Knock.BulkOperations do
  @moduledoc """
  Knock resources for accessing Bulk Operations
  """
  alias Knock.Api

  @doc """
  Retrieves the current status of the bulk operation
  """
  @spec get(Client.t(), String.t()) :: Api.response()
  def get(client, bulk_op_id) do
    Api.get(client, "/bulk_operations/#{bulk_op_id}")
  end
end
