defmodule Knock.Objects do
  @moduledoc """
  Knock resources for accessing Objects
  """
  import Knock.ResourceHelpers, only: [maybe_json_encode_param: 2]

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

  @doc """
  Unsets the channel data for the given channel id.
  """
  @spec unset_channel_data(Client.t(), String.t(), String.t(), String.t()) ::
          Api.response()
  def unset_channel_data(client, collection, id, channel_id) do
    Api.delete(client, "/objects/#{collection}/#{id}/channel_data/#{channel_id}")
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
  # - trigger_data: trigger payload to filter messages with
  """
  @spec get_messages(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def get_messages(client, collection, id, options \\ []) do
    options = maybe_json_encode_param(options, :trigger_data)

    Api.get(client, "/objects/#{collection}/#{id}/messages", query: options)
  end

  ##
  # Preferences
  ##

  @default_preference_set_id "default"

  @doc """
  Returns all of the users preference sets
  """
  @spec get_all_preferences(Client.t(), String.t(), String.t()) :: Api.response()
  def get_all_preferences(client, collection, id) do
    Api.get(client, "/objects/#{collection}/#{id}/preferences")
  end

  @doc """
  Returns the preference set for the user.
  """
  @spec get_preferences(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def get_preferences(client, collection, id, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.get(client, "/objects/#{collection}/#{id}/preferences/#{preference_set_id}")
  end

  @doc """
  Sets an entire preference set for the user. Will overwrite any existing data.
  """
  @spec set_preferences(Client.t(), String.t(), String.t(), map(), Keyword.t()) :: Api.response()
  def set_preferences(client, collection, id, preferences, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(client, "/objects/#{collection}/#{id}/preferences/#{preference_set_id}", preferences)
  end

  @doc """
  Sets the channel type preferences for the user.
  """
  @spec set_channel_types_preferences(Client.t(), String.t(), String.t(), map(), Keyword.t()) ::
          Api.response()
  def set_channel_types_preferences(client, collection, id, channel_types, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/objects/#{collection}/#{id}/preferences/#{preference_set_id}/channel_types",
      channel_types
    )
  end

  @doc """
  Sets the channel type preference for the user.
  """
  @spec set_channel_type_preferences(
          Client.t(),
          String.t(),
          String.t(),
          String.t(),
          boolean(),
          Keyword.t()
        ) ::
          Api.response()
  def set_channel_type_preferences(client, collection, id, channel_type, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/objects/#{collection}/#{id}/preferences/#{preference_set_id}/channel_types/#{channel_type}",
      %{subscribed: setting}
    )
  end

  @doc """
  Sets the workflow preferences for the user.
  """
  @spec set_workflows_preferences(Client.t(), String.t(), String.t(), map(), Keyword.t()) ::
          Api.response()
  def set_workflows_preferences(client, collection, id, workflows, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/objects/#{collection}/#{id}/preferences/#{preference_set_id}/workflows",
      workflows
    )
  end

  @doc """
  Sets the workflow preference for the user.
  """
  @spec set_workflow_preferences(
          Client.t(),
          String.t(),
          String.t(),
          String.t(),
          map() | boolean(),
          Keyword.t()
        ) :: Api.response()
  def set_workflow_preferences(client, collection, id, workflow_key, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/objects/#{collection}/#{id}/preferences/#{preference_set_id}/workflows/#{workflow_key}",
      build_setting_param(setting)
    )
  end

  @doc """
  Sets the category preferences for the user.
  """
  @spec set_categories_preferences(Client.t(), String.t(), String.t(), map(), Keyword.t()) ::
          Api.response()
  def set_categories_preferences(client, collection, id, categories, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/objects/#{collection}/#{id}/preferences/#{preference_set_id}/categories",
      categories
    )
  end

  @doc """
  Sets the category preference for the user.
  """
  @spec set_category_preferences(
          Client.t(),
          String.t(),
          String.t(),
          String.t(),
          map() | boolean(),
          Keyword.t()
        ) :: Api.response()
  def set_category_preferences(client, collection, id, category_key, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/objects/#{collection}/#{id}/preferences/#{preference_set_id}/categories/#{category_key}",
      build_setting_param(setting)
    )
  end

  defp build_setting_param(setting) when is_map(setting), do: setting
  defp build_setting_param(setting), do: %{subscribed: setting}
end
