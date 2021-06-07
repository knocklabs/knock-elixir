defmodule Knock.Preferences do
  @moduledoc """
  Knock resources for accessing preferences
  """
  alias Knock.Api

  @default_id "default"

  @doc """
  Returns all of the users preference sets
  """
  def get_all(client, user_id) do
    Api.get(client, "/users/#{user_id}/preferences")
  end

  @doc """
  Returns the preference set for the user
  """
  def get(client, user_id, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_id)

    Api.get(client, "/users/#{user_id}/preferences/#{preference_set_id}")
  end

  @doc """
  Sets the entire preference set for the user
  """
  def set(client, user_id, preferences, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_id)

    Api.put(client, "/users/#{user_id}/preferences/#{preference_set_id}", preferences)
  end

  @doc """
  Sets the channel type preferences for the user
  """
  def set_channel_types(client, user_id, channel_types, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/channel_types",
      channel_types
    )
  end

  @doc """
  Sets the channel type preferences for the user
  """
  def set_channel_type(client, user_id, channel_type, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/channel_types/#{channel_type}",
      %{subscribed: setting}
    )
  end

  @doc """
  Sets the workflow preferences for the user
  """
  def set_workflows(client, user_id, workflows, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/workflows",
      workflows
    )
  end

  @doc """
  Sets the workflow preference for the user
  """
  def set_workflow(client, user_id, workflow_key, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/workflows/#{workflow_key}",
      %{subscribed: setting}
    )
  end

  @doc """
  Sets the workflow preferences for the user
  """
  def set_categories(client, user_id, categories, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/categories",
      categories
    )
  end

  @doc """
  Sets the workflow preference for the user
  """
  def set_category(client, user_id, category_key, setting, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_id)

    Api.put(
      client,
      "/users/#{user_id}/preferences/#{preference_set_id}/categories/#{category_key}",
      %{subscribed: setting}
    )
  end
end
