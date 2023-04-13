defmodule Knock.Users do
  @moduledoc """
  Knock resources for accessing users
  """
  import Knock.ResourceHelpers, only: [maybe_json_encode_param: 2]

  alias Knock.Api
  alias Knock.Client

  @default_preference_set_id "default"

  @doc """
  Returns information about the user from the `user_id` given.
  """
  @spec get_user(Client.t(), String.t()) :: Api.response()
  @deprecated "Use get/2 instead"
  def get_user(client, user_id) do
    get(client, user_id)
  end

  @doc """
  Returns information about the user.
  """
  @spec get(Client.t(), String.t()) :: Api.response()
  def get(client, user_id) do
    Api.get(client, "/users/#{user_id}")
  end

  @doc """
  Upserts the user specified via the `user_id` with the given properties.
  """
  @spec identify(Client.t(), String.t(), map()) :: Api.response()
  def identify(client, user_id, properties) do
    Api.put(client, "/users/#{user_id}", properties)
  end

  @doc """
  Issues a delete request against the user specified
  """
  @spec delete(Client.t(), String.t()) :: Api.response()
  def delete(client, user_id) do
    Api.delete(client, "/users/#{user_id}")
  end

  @doc """
  Returns a feed for the user with the given channel_id. Optionally supports all of the options
  for fetching the feed.

  # Available optional parameters:
  #
  # - page_size: specify size of the page to be returned by the api. (max limit: 50)
  # - after:  after cursor for pagination
  # - before: before cursor for pagination
  # - status: list of statuses to filter feed items with
  # - tenant: tenant_id to filter messages with
  # - has_tenant: optionally scope items by a tenant id or no tenant
  # - archived: scope items by a given archived status (defaults to "exclude")
  # - trigger_data: trigger payload to filter feed items with
  """
  @spec get_feed(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def get_feed(client, user_id, channel_id, options \\ []) do
    options = maybe_json_encode_param(options, :trigger_data)

    Api.get(client, "/users/#{user_id}/feeds/#{channel_id}", query: options)
  end

  @doc """
  Merges the user specified with `from_user_id` into the user specified with `user_id`.
  """
  @spec merge(Client.t(), String.t(), String.t()) :: Api.response()
  def merge(client, user_id, from_user_id) do
    Api.post(client, "/users/#{user_id}/merge", %{from_user_id: from_user_id})
  end

  ##
  # Bulk actions
  ##

  @doc """
  Bulk identifies the list of users given. Can accept a maximum of 100 users at a time.
  """
  @spec bulk_identify(Client.t(), [map()]) :: Api.response()
  def bulk_identify(client, users) do
    Api.post(client, "/users/bulk/identify", %{users: users})
  end

  @doc """
  Bulk deletes the list of users given. Can accept a maximum of 100 users at a time.
  """
  @spec bulk_delete(Client.t(), [String.t()]) :: Api.response()
  def bulk_delete(client, user_ids) do
    Api.post(client, "/users/bulk/delete", %{user_ids: user_ids})
  end

  ##
  # Channel data
  ##

  @doc """
  Returns user's channel data for the given channel id.
  """
  @spec get_channel_data(Client.t(), String.t(), String.t()) :: Api.response()
  def get_channel_data(client, user_id, channel_id) do
    Api.get(client, "/users/#{user_id}/channel_data/#{channel_id}")
  end

  @doc """
  Upserts user's channel data for the given channel id.
  """
  @spec set_channel_data(Client.t(), String.t(), String.t(), map()) :: Api.response()
  def set_channel_data(client, user_id, channel_id, channel_data) do
    Api.put(client, "/users/#{user_id}/channel_data/#{channel_id}", %{data: channel_data})
  end

  @doc """
  Unsets the user's channel data for the given channel id.
  """
  @spec unset_channel_data(Client.t(), String.t(), String.t()) :: Api.response()
  def unset_channel_data(client, user_id, channel_id) do
    Api.delete(client, "/users/#{user_id}/channel_data/#{channel_id}")
  end

  ##
  # Preferences
  ##

  @doc """
  Returns all of the users preference sets
  """
  @spec get_all_preferences(Client.t(), String.t()) :: Api.response()
  def get_all_preferences(client, user_id) do
    Api.get(client, "/users/#{user_id}/preferences")
  end

  @doc """
  Returns the preference set for the user.
  """
  @spec get_preferences(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_preferences(client, user_id, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.get(client, "/users/#{user_id}/preferences/#{preference_set_id}")
  end

  @doc """
  Sets an entire preference set for the user. Will overwrite any existing data.
  """
  @spec set_preferences(Client.t(), String.t(), map(), Keyword.t()) :: Api.response()
  def set_preferences(client, user_id, preferences, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(client, "/users/#{user_id}/preferences/#{preference_set_id}", preferences)
  end

  @doc """
  Bulk sets the preferences given for the list of user ids. Will overwrite the any existing
  preferences for these users.
  """
  @spec bulk_set_preferences(Client.t(), [String.t()], map(), Keyword.t()) :: Api.response()
  def bulk_set_preferences(client, user_ids, preferences, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)
    preferences = Map.put_new(preferences, "id", preference_set_id)

    Api.post(client, "/users/bulk/preferences", %{
      user_ids: user_ids,
      preferences: preferences
    })
  end

  @doc """
  Sets the channel type preferences for the user.
  """
  @spec set_channel_types_preferences(Client.t(), String.t(), map(), Keyword.t()) ::
          Api.response()
  def set_channel_types_preferences(client, user_id, channel_types, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/channel_types",
      channel_types
    )
  end

  @doc """
  Sets the channel type preference for the user.
  """
  @spec set_channel_type_preferences(Client.t(), String.t(), String.t(), boolean(), Keyword.t()) ::
          Api.response()
  def set_channel_type_preferences(client, user_id, channel_type, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/channel_types/#{channel_type}",
      %{subscribed: setting}
    )
  end

  @doc """
  Sets the workflow preferences for the user.
  """
  @spec set_workflows_preferences(Client.t(), String.t(), map(), Keyword.t()) :: Api.response()
  def set_workflows_preferences(client, user_id, workflows, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/workflows",
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
          map() | boolean(),
          Keyword.t()
        ) :: Api.response()
  def set_workflow_preferences(client, user_id, workflow_key, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/workflows/#{workflow_key}",
      build_setting_param(setting)
    )
  end

  @doc """
  Sets the category preferences for the user.
  """
  @spec set_categories_preferences(Client.t(), String.t(), map(), Keyword.t()) :: Api.response()
  def set_categories_preferences(client, user_id, categories, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/categories",
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
          map() | boolean(),
          Keyword.t()
        ) :: Api.response()
  def set_category_preferences(client, user_id, category_key, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/categories/#{category_key}",
      build_setting_param(setting)
    )
  end

  ##
  # Messages
  ##

  @doc """
  Returns paginated messages for the given user

  # Available optional parameters:
  #
  # - page_size: specify size of the page to be returned by the api. (max limit: 50)
  # - after:  after cursor for pagination
  # - before: before cursor for pagination
  # - status: list of statuses to filter messages with
  # - tenant: tenant_id to filter messages with
  # - channel_id: channel_id to filter messages with
  # - source: workflow key to filter messages with
  # - trigger_data: trigger payload to filter messages with
  """
  @spec get_messages(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_messages(client, id, options \\ []) do
    options = maybe_json_encode_param(options, :trigger_data)

    Api.get(client, "/users/#{id}/messages", query: options)
  end

  ##
  # Schedules
  ##

  @doc """
  Returns paginated schedules for the given user

  # Available optional parameters:
  #
  # - page_size: specify size of the page to be returned by the api. (max limit: 50)
  # - after:  after cursor for pagination
  # - before: before cursor for pagination
  # - tenant: tenant_id to filter messages with
  # - workflow: workflow key to filter messages with
  """
  @spec get_schedules(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_schedules(client, id, options \\ []) do
    Api.get(client, "/users/#{id}/schedules", query: options)
  end

  defp build_setting_param(setting) when is_map(setting), do: setting
  defp build_setting_param(setting), do: %{subscribed: setting}
end
