defmodule Knock.Tenants do
  @moduledoc """
  Knock resources for accessing Tenants
  """
  alias Knock.Api
  alias Knock.Client

  @doc """
  Upserts the given tenant with the tenant data provided.
  """
  @spec set(Client.t(), String.t(), map()) :: Api.response()
  def set(client, id, tenant_data) do
    Api.put(client, "/tenants/#{id}", tenant_data)
  end

  @doc """
  Gets the given tenant.
  """
  @spec get(Client.t(), String.t()) :: Api.response()
  def get(client, id) do
    Api.get(client, "/tenants/#{id}")
  end

  @doc """
  Deletes the given tenant.
  """
  @spec delete(Client.t(), String.t()) :: Api.response()
  def delete(client, id) do
    Api.delete(client, "/tenants/#{id}")
  end

  @doc """
  Returns paginated tenants for environment

  # Available optional parameters:
  #
  # - page_size: specify size of the page to be returned by the api. (max limit: 50)
  # - after:  after cursor for pagination
  # - before: before cursor for pagination
  # - tenant_id: id of the tenant to filter for
  # - name: name of the tenant to filter for
  """

  @spec list(Client.t(), Keyword.t()) :: Api.response()
  def list(client, options \\ []) do
    Api.get(client, "/tenants", query: options)
  end
end
