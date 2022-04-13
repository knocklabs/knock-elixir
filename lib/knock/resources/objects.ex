defmodule Knock.Objects do
  @moduledoc """
  Knock resources for accessing Objects
  """
  alias Knock.Api
  alias Knock.Client

  @typedoc """
  An object reference is how we refer to a particular object in a collection
  """
  @type ref :: %{id: :string, collection: :string}

  @doc """
  Builds an object reference, which can be used in workflow trigger calls.
  """
  @spec build_ref(String.t(), String.t()) :: ref()
  def build_ref(collection, id), do: %{id: id, collection: collection}

  @doc """
  Upserts the given object in the collection with the attrs provided.
  """
  @spec set(Client.t(), String.t(), String.t(), map()) :: Api.response()
  def set(client, collection, id, attrs) do
    Api.put(client, "/objects/#{collection}/#{id}", attrs)
  end

  @doc """
  Gets the given object.
  """
  @spec get(Client.t(), String.t(), String.t()) :: Api.response()
  def get(client, collection, id) do
    Api.get(client, "/objects/#{collection}/#{id}")
  end

  @doc """
  Deletes the given object.
  """
  @spec delete(Client.t(), String.t(), String.t()) :: Api.response()
  def delete(client, collection, id) do
    Api.delete(client, "/objects/#{collection}/#{id}")
  end

  ##
  # Bulk functions
  ##

  @doc """
  Bulk upserts one or more objects in a collection.
  """
  @spec bulk_set(Client.t(), String.t(), [map()]) :: Api.response()
  def bulk_set(client, collection, objects) do
    Api.post(client, "/objects/#{collection}/bulk/set", %{objects: objects})
  end

  @doc """
  Bulk deletes one or more objects in a collection.
  """
  @spec bulk_delete(Client.t(), String.t(), [String.t()]) :: Api.response()
  def bulk_delete(client, collection, object_ids) do
    Api.post(client, "/objects/#{collection}/bulk/delete", %{object_ids: object_ids})
  end

  ##
  # Channel data
  ##

  @doc """
  Returns channel data for the given channel id.
  """
  @spec get_channel_data(Client.t(), String.t(), String.t(), String.t()) :: Api.response()
  def get_channel_data(client, collection, id, channel_id) do
    Api.get(client, "/objects/#{collection}/#{id}/channel_data/#{channel_id}")
  end

  @doc """
  Upserts channel data for the given channel id.
  """
  @spec set_channel_data(Client.t(), String.t(), String.t(), String.t(), map()) :: Api.response()
  def set_channel_data(client, collection, id, channel_id, channel_data) do
    Api.put(client, "/objects/#{collection}/#{id}/channel_data/#{channel_id}", %{
      data: channel_data
    })
  end

  ##
  # Messages
  ##

  @doc """
  Returns paginated messages for the given object

  # Available optional parameters:
  #
  # - page_size: specify size of the page to be returned by the api.  (max limit: 50)
  # - after:  after cursor for pagination
  # - before: before cursor for pagination
  # - status: list of statuses to filter messages with
  # - tenant: tenant_id to filter messages with
  # - channel_id: channel_id to filter messages with
  # - source: workflow key to filter messages with
  """
  @spec get_messages(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def get_messages(client, collection, id, options \\ []) do
    Api.get(client, "/objects/#{collection}/#{id}/messages", query: options)
  end
end
