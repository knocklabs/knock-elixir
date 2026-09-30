defmodule Knock.Objects do
  @moduledoc """
  Knock resources for accessing Objects
  """
  import Knock.ResourceHelpers, only: [maybe_json_encode_param: 3]

  alias Knock.Api
  alias Knock.Client

  @typedoc """
  An object reference is how we refer to a particular object in a collection
  """
  @type ref :: %{id: :string, collection: :string}

  @doc """
  Returns paginated list of objects for a collection

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  """
  @spec list(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def list(client, collection, options \\ []) do
    Api.get(client, "/objects/#{collection}", query: options)
  end

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

  @doc """
  Creates a bulk operation to create subscriptions for a set of recipients to a
  set of objects within the given collection.

  Each entry in the provided subscriptions list should have the properties:

  - id: the id of an object for subscribing
  - recipients: a list of recipients to subscribe to the object
  - properties (optional): a map of properties to apply to each recipient subscription
  """
  @spec bulk_add_subscriptions(Client.t(), String.t(), [map()]) :: Api.response()
  def bulk_add_subscriptions(client, collection, subscriptions) do
    Api.post(client, "/objects/#{collection}/bulk/subscriptions/add", %{
      subscriptions: subscriptions
    })
  end

  @doc """
  Creates a bulk operation to delete subscriptions for a set of recipients from a set of
  objects within the given collection.

  Each entry in the provided subscriptions list should have the properties:

  - id: the id of the object to remove subscriptions from
  - recipients: a list of recipients to unsubscribe from the object
  """
  @spec bulk_delete_subscriptions(Client.t(), String.t(), [map()]) :: Api.response()
  def bulk_delete_subscriptions(client, collection, subscriptions) do
    Api.post(client, "/objects/#{collection}/bulk/subscriptions/delete", %{
      subscriptions: subscriptions
    })
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

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:status` - list of delivery statuses to filter messages with
  * `:engagement_status` - list of engagement statuses to filter messages with
  * `:tenant` - tenant_id to filter messages with
  * `:channel_id` - channel_id to filter messages with
  * `:source` - workflow key to filter messages with
  * `:trigger_data` - trigger payload to filter messages with, as a map or a JSON-encoded string
  * `:inserted_at` - map of `:gt`, `:gte`, `:lt` and/or `:lte` timestamps to filter messages with
  """
  @spec get_messages(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def get_messages(client, collection, id, options \\ []) do
    options = maybe_json_encode_param(options, :trigger_data, client.json_client)

    Api.get(client, "/objects/#{collection}/#{id}/messages", query: options)
  end

  ##
  # Schedules
  ##

  @doc """
  Returns paginated schedules for the given object

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:tenant` - tenant_id to filter messages with
  * `:workflow` - workflow key to filter messages with
  """
  @spec get_schedules(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def get_schedules(client, collection, id, options \\ []) do
    Api.get(client, "/objects/#{collection}/#{id}/schedules", query: options)
  end

  ##
  # Subscriptions
  ##

  @doc """
  Returns paginated subscriptions for the given object

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:include` - list of associated resources to include, e.g. `["preferences"]`
  * `:recipients` - list of recipients (user ids or `%{id: id, collection: collection}` object
    references) to filter subscribers of the object
  """
  @spec list_subscriptions(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def list_subscriptions(client, collection, id, options \\ []) do
    Api.get(client, "/objects/#{collection}/#{id}/subscriptions", query: options)
  end

  @doc """
  Returns paginated subscriptions for the given object as recipient

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  """
  @spec get_subscriptions(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def get_subscriptions(client, collection, id, options \\ []) do
    options = Keyword.put(options, :mode, "recipient")
    Api.get(client, "/objects/#{collection}/#{id}/subscriptions", query: options)
  end

  @doc """
  Adds subscriptions for all recipients passed as arguments

  Expected properties:
  - recipients: list of recipients to create subscriptions for
  - properties: data to be stored at the subscription level for each recipient
  """
  @spec add_subscriptions(Client.t(), String.t(), String.t(), map()) :: Api.response()
  def add_subscriptions(client, collection, id, params) do
    Api.post(client, "/objects/#{collection}/#{id}/subscriptions", params)
  end

  @doc """
  Delete subscriptions for recipients passed as arguments

  Expected properties:
  - recipients: list of recipients to create subscriptions for
  """
  @spec delete_subscriptions(
          Client.t(),
          String.t(),
          String.t(),
          map()
        ) :: Api.response()
  def delete_subscriptions(client, collection, id, params) do
    recipients = Map.get(params, :recipients) || Map.get(params, "recipients")

    Api.delete(client, "/objects/#{collection}/#{id}/subscriptions",
      body: %{recipients: recipients}
    )
  end

  ##
  # Preferences
  ##

  @default_preference_set_id "default"

  @doc """
  Returns all of the object's preference sets
  """
  @spec get_all_preferences(Client.t(), String.t(), String.t()) :: Api.response()
  def get_all_preferences(client, collection, id) do
    Api.get(client, "/objects/#{collection}/#{id}/preferences")
  end

  @doc """
  Returns the preference set for the object.
  """
  @spec get_preferences(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def get_preferences(client, collection, id, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.get(client, "/objects/#{collection}/#{id}/preferences/#{preference_set_id}")
  end

  @doc """
  Sets an entire preference set for the object. Will overwrite any existing data.
  """
  @spec set_preferences(Client.t(), String.t(), String.t(), map(), Keyword.t()) :: Api.response()
  def set_preferences(client, collection, id, preferences, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(client, "/objects/#{collection}/#{id}/preferences/#{preference_set_id}", preferences)
  end

  @doc """
  Unsets (deletes) the preference set for the object.

  ## Available optional parameters:

  * `:preference_set` - id of the preference set to delete (defaults to `"default"`)
  """
  @spec unset_preferences(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def unset_preferences(client, collection, id, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.delete(client, "/objects/#{collection}/#{id}/preferences/#{preference_set_id}")
  end

  @doc """
  Sets the channel type preferences for the object.

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/5` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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
  Sets the channel type preference for the object.

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/5` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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
  Sets the workflow preferences for the object.

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/5` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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
  Sets the workflow preference for the object.

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/5` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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
  Sets the category preferences for the object.

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/5` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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
  Sets the category preference for the object.

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/5` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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
