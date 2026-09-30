defmodule Knock.Tenants do
  @moduledoc """
  Knock resources for accessing Tenants
  """
  alias Knock.Api
  alias Knock.Client

  @doc """
  Upserts the given tenant with the tenant data provided.

  ## Available optional parameters:

  * `:resolve_full_preference_settings` - when true, merges environment-level default
    preferences into the tenant's `settings.preference_set` in the response
  """
  @spec set(Client.t(), String.t(), map(), Keyword.t()) :: Api.response()
  def set(client, id, tenant_data, options \\ []) do
    Api.put(client, "/tenants/#{id}", tenant_data, query: options)
  end

  @doc """
  Gets the given tenant.

  ## Available optional parameters:

  * `:resolve_full_preference_settings` - when true, merges environment-level default
    preferences into the tenant's `settings.preference_set` in the response
  """
  @spec get(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get(client, id, options \\ []) do
    Api.get(client, "/tenants/#{id}", query: options)
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

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:tenant_id` - id of the tenant to filter for
  * `:name` - name of the tenant to filter for
  """
  @spec list(Client.t(), Keyword.t()) :: Api.response()
  def list(client, options \\ []) do
    Api.get(client, "/tenants", query: options)
  end

  ##
  # Bulk actions
  ##

  @doc """
  Bulk upserts the list of tenants given. Returns a bulk operation.
  """
  @spec bulk_set(Client.t(), [map()]) :: Api.response()
  def bulk_set(client, tenants) do
    Api.post(client, "/tenants/bulk/set", %{tenants: tenants})
  end

  @doc """
  Bulk deletes the list of tenant ids given. Returns a bulk operation.
  """
  @spec bulk_delete(Client.t(), [String.t()]) :: Api.response()
  def bulk_delete(client, tenant_ids) do
    Api.post(client, "/tenants/bulk/delete", %{}, query: [tenant_ids: tenant_ids])
  end
end
