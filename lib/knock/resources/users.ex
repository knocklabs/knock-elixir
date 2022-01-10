defmodule Knock.Users do
  @moduledoc """
  Knock resources for accessing users
  """
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
  Returns information about the user
  """
  @spec get(Client.t(), String.t()) :: Api.response()
  def get(client, user_id) do
    Api.get(client, "/users/#{user_id}")
  end

  @doc """
  Sets the given properties on the user specified via the `user_id`. Will perform
  an upsert of the user.
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
  """
  def get_feed(client, user_id, channel_id, options \\ []) do
    query = URI.encode_query(options)

    Api.get(client, "/users/#{user_id}/feeds/#{channel_id}", query: query)
  end

  ##
  # Bulk actions
  ##

  @doc """
  Bulk identifies the list of users given. Can accept a maximum of 100 users at a time.
  """
  def bulk_identify(client, users) do
    Api.post(client, "/users/bulk/identify", %{users: users})
  end

  @doc """
  Bulk deletes the list of users given. Can accept a maximum of 100 users at a time.
  """
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

  ##
  # Preferences
  ##

  @doc """
  Returns all of the users preference sets
  """
  def get_all_preferences(client, user_id) do
    Api.get(client, "/users/#{user_id}/preferences")
  end

  @doc """
  Returns the preference set for the user
  """
  def get_preferences(client, user_id, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.get(client, "/users/#{user_id}/preferences/#{preference_set_id}")
  end

  @doc """
  Sets the entire preference set for the user
  """
  def set_preferences(client, user_id, preferences, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(client, "/users/#{user_id}/preferences/#{preference_set_id}", preferences)
  end

  @doc """
  Bulk sets the preferences given for the list of user ids.
  """
  def bulk_set_preferences(client, user_ids, preferences, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)
    preferences = Map.put_new(preferences, "id", preference_set_id)

    Api.post(client, "/users/bulk/preferences", %{
      user_ids: user_ids,
      preferences: preferences
    })
  end

  @doc """
  Sets the channel type preferences for the user
  """
  def set_channel_types_preferences(client, user_id, channel_types, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/channel_types",
      channel_types
    )
  end

  @doc """
  Sets the channel type preferences for the user
  """
  def set_channel_type_preferences(client, user_id, channel_type, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/channel_types/#{channel_type}",
      %{subscribed: setting}
    )
  end

  @doc """
  Sets the workflow preferences for the user
  """
  def set_workflows_preferences(client, user_id, workflows, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/workflows",
      workflows
    )
  end

  @doc """
  Sets the workflow preference for the user
  """
  def set_workflow_preferences(client, user_id, workflow_key, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/workflows/#{workflow_key}",
      build_setting_param(setting)
    )
  end

  @doc """
  Sets the workflow preferences for the user
  """
  def set_categories_preferences(client, user_id, categories, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/categories",
      categories
    )
  end

  @doc """
  Sets the workflow preference for the user
  """
  def set_category_preferences(client, user_id, category_key, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/categories/#{category_key}",
      build_setting_param(setting)
    )
  end

  defp build_setting_param(setting) when is_map(setting), do: setting
  defp build_setting_param(setting), do: %{subscribed: setting}
end
