defmodule Knock.Preferences do
  @moduledoc """
  Knock resources for accessing preferences. Note: this module and all of the functions here are
  deprecated and will be removed in the next version.
  """
  alias Knock.Users

  @doc """
  Returns all of the users preference sets
  """
  @deprecated "Use Users.get_all_preferences/2 instead"
  def get_all(client, user_id) do
    Users.get_all_preferences(client, user_id)
  end

  @doc """
  Returns the preference set for the user
  """
  @deprecated "Use Users.get_preferences/3 instead"
  def get(client, user_id, options \\ []) do
    Users.get_preferences(client, user_id, options)
  end

  @doc """
  Sets the entire preference set for the user
  """
  @deprecated "Use Users.set_preferences/4 instead"
  def set(client, user_id, preferences, options \\ []) do
    Users.set_preferences(client, user_id, preferences, options)
  end

  @doc """
  Sets the channel type preferences for the user
  """
  @deprecated "Use Users.set_channel_types_preferences/4 instead"
  def set_channel_types(client, user_id, channel_types, options \\ []) do
    Users.set_channel_types_preferences(client, user_id, channel_types, options)
  end

  @doc """
  Sets the channel type preferences for the user
  """
  @deprecated "Use Users.set_channel_type_preferences/5 instead"
  def set_channel_type(client, user_id, channel_type, setting, options \\ []) do
    Users.set_channel_type_preferences(client, user_id, channel_type, setting, options)
  end

  @doc """
  Sets the workflow preferences for the user
  """
  @deprecated "Use Users.set_workflows_preferences/4 instead"
  def set_workflows(client, user_id, workflows, options \\ []) do
    Users.set_workflows_preferences(client, user_id, workflows, options)
  end

  @doc """
  Sets the workflow preference for the user
  """
  @deprecated "Use Users.set_workflow_preferences/5 instead"
  def set_workflow(client, user_id, workflow_key, setting, options \\ []) do
    Users.set_workflow_preferences(client, user_id, workflow_key, setting, options)
  end

  @doc """
  Sets the workflow preferences for the user
  """
  @deprecated "Use Users.set_categories_preferences/4 instead"
  def set_categories(client, user_id, categories, options \\ []) do
    Users.set_categories_preferences(client, user_id, categories, options)
  end

  @doc """
  Sets the workflow preference for the user
  """
  @deprecated "Use Users.set_category_preferences/5 instead"
  def set_category(client, user_id, category_key, setting, options \\ []) do
    Users.set_category_preferences(client, user_id, category_key, setting, options)
  end
end
