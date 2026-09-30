defmodule Knock.Users do
  @moduledoc """
  Knock resources for accessing users
  """
  import Knock.ResourceHelpers, only: [maybe_json_encode_param: 3]

  alias Knock.Api
  alias Knock.Client

  @default_preference_set_id "default"

  @doc """
  Returns paginated list of users

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `before` - before cursor for pagination
  """
  @spec list(Client.t(), Keyword.t()) :: Api.response()
  def list(client, options \\ []) do
    Api.get(client, "/users", query: options)
  end

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

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:status` - status to filter feed items with, one of `unread`, `read`, `unseen`, `seen`
    or `all`
  * `:source` - workflow key to filter feed items with
  * `:tenant` - tenant_id to filter messages with
  * `:has_tenant` - optionally scope items by a tenant id or no tenant
  * `:archived` - scope items by a given archived status (`exclude`, `include` or `only`,
    defaults to `exclude`)
  * `:workflow_categories` - list of workflow categories to filter feed items with
  * `:trigger_data` - trigger payload to filter feed items with, as a map or a JSON-encoded
    string
  * `:locale` - locale to render feed items in
  * `:exclude` - comma-separated list of fields to exclude from the response
  * `:mode` - `compact` or `rich`
  * `:inserted_at` - map of `:gt`, `:gte`, `:lt` and/or `:lte` timestamps to filter feed items
    with, e.g. `%{gte: "2024-01-01T00:00:00Z"}`
  """
  @spec get_feed(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def get_feed(client, user_id, channel_id, options \\ []) do
    options = maybe_json_encode_param(options, :trigger_data, client.json_client)

    Api.get(client, "/users/#{user_id}/feeds/#{channel_id}", query: options)
  end

  @doc """
  Returns the feed settings for the user and the given in-app feed channel_id.
  """
  @spec get_feed_settings(Client.t(), String.t(), String.t()) :: Api.response()
  def get_feed_settings(client, user_id, channel_id) do
    Api.get(client, "/users/#{user_id}/feeds/#{channel_id}/settings")
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

  ## Available optional parameters:

  * `:preference_set` - id of the preference set to return (defaults to `"default"`)
  * `:tenant` - tenant id to resolve the preference set for
  """
  @spec get_preferences(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_preferences(client, user_id, options \\ []) do
    {preference_set_id, query} =
      Keyword.pop(options, :preference_set, @default_preference_set_id)

    Api.get(client, "/users/#{user_id}/preferences/#{preference_set_id}", query: query)
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
  Unsets (deletes) the preference set for the user.

  ## Available optional parameters:

  * `:preference_set` - id of the preference set to delete (defaults to `"default"`)
  """
  @spec unset_preferences(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def unset_preferences(client, user_id, options \\ []) do
    preference_set_id = Keyword.get(options, :preference_set, @default_preference_set_id)

    Api.delete(client, "/users/#{user_id}/preferences/#{preference_set_id}")
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

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/4` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/4` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/4` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/4` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/4` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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

  Note: the underlying endpoint is deprecated in the Knock API. Prefer `set_preferences/4` with
  `"__persistence_strategy__" => "merge"` to update part of a preference set.
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

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:status` - list of delivery statuses to filter messages with
  * `:engagement_status` - list of engagement statuses to filter messages with
  * `:message_ids` - list of message ids to filter messages with
  * `:tenant` - tenant_id to filter messages with
  * `:channel_id` - channel_id to filter messages with
  * `:source` - workflow key to filter messages with
  * `:workflow_categories` - list of workflow categories to filter messages with
  * `:workflow_run_id` - workflow run id to filter messages with
  * `:workflow_recipient_run_id` - workflow recipient run id to filter messages with
  * `:trigger_data` - trigger payload to filter messages with, as a map or a JSON-encoded string
  * `:inserted_at` - map of `:gt`, `:gte`, `:lt` and/or `:lte` timestamps to filter messages with
  """
  @spec get_messages(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_messages(client, id, options \\ []) do
    options = maybe_json_encode_param(options, :trigger_data, client.json_client)

    Api.get(client, "/users/#{id}/messages", query: options)
  end

  ##
  # Schedules
  ##

  @doc """
  Returns paginated schedules for the given user

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:tenant` - tenant_id to filter messages with
  * `:workflow` - workflow key to filter messages with
  """
  @spec get_schedules(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_schedules(client, id, options \\ []) do
    Api.get(client, "/users/#{id}/schedules", query: options)
  end

  ##
  # Subscriptions
  ##

  @doc """
  Returns paginated subscriptions for the given user

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:include` - list of associated resources to include, e.g. `["preferences"]`
  * `:objects` - list of object references (`%{id: id, collection: collection}`) to filter
    subscriptions with
  """
  @spec get_subscriptions(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_subscriptions(client, id, options \\ []) do
    Api.get(client, "/users/#{id}/subscriptions", query: options)
  end

  ##
  # Guides
  ##

  @doc """
  Returns the guides for the user on the given guide channel.

  ## Available optional parameters:

  * `:tenant` - tenant id to scope guides to
  * `:type` - guide type to filter guides with
  * `:data` - data to evaluate guide targeting against, as a map or a JSON-encoded string
  """
  @spec get_guides(Client.t(), String.t(), String.t(), Keyword.t()) :: Api.response()
  def get_guides(client, user_id, channel_id, options \\ []) do
    options = maybe_json_encode_param(options, :data, client.json_client)

    Api.get(client, "/users/#{user_id}/guides/#{channel_id}", query: options)
  end

  @doc """
  Records that the user has seen a guide.

  Expected properties:
  - channel_id: the guide channel id
  - guide_id: the guide id
  - guide_key: the guide key
  - guide_step_ref: the ref of the guide step
  - content: the content of the guide step
  - data (optional): data used when rendering the guide
  - tenant (optional): tenant id the guide was seen in
  """
  @spec mark_guide_as_seen(Client.t(), String.t(), map()) :: Api.response()
  def mark_guide_as_seen(client, user_id, params) do
    Api.put(client, "/users/#{user_id}/guides/messages/seen", params)
  end

  @doc """
  Records that the user has interacted with a guide.

  Expected properties:
  - channel_id: the guide channel id
  - guide_id: the guide id
  - guide_key: the guide key
  - guide_step_ref: the ref of the guide step
  - metadata (optional): metadata about the interaction
  - tenant (optional): tenant id the guide was interacted with in
  """
  @spec mark_guide_as_interacted(Client.t(), String.t(), map()) :: Api.response()
  def mark_guide_as_interacted(client, user_id, params) do
    Api.put(client, "/users/#{user_id}/guides/messages/interacted", params)
  end

  @doc """
  Records that the user has archived a guide.

  Expected properties:
  - channel_id: the guide channel id
  - guide_id: the guide id
  - guide_key: the guide key
  - guide_step_ref: the ref of the guide step
  - is_final (optional): whether this is the final step of the guide
  - unthrottled (optional): whether the guide is unthrottled
  - tenant (optional): tenant id the guide was archived in
  """
  @spec mark_guide_as_archived(Client.t(), String.t(), map()) :: Api.response()
  def mark_guide_as_archived(client, user_id, params) do
    Api.put(client, "/users/#{user_id}/guides/messages/archived", params)
  end

  @doc """
  Unarchives a guide for the user.

  Expected properties:
  - guide_key: the guide key
  - tenant (optional): tenant id to unarchive the guide in
  """
  @spec mark_guide_as_unarchived(Client.t(), String.t(), map()) :: Api.response()
  def mark_guide_as_unarchived(client, user_id, params) do
    Api.delete(client, "/users/#{user_id}/guides/messages/archived", body: params)
  end

  @doc """
  Resets the user's engagement with a guide.

  Expected properties:
  - guide_key: the guide key
  - tenant (optional): tenant id to reset the guide engagement in
  """
  @spec reset_guide_engagement(Client.t(), String.t(), map()) :: Api.response()
  def reset_guide_engagement(client, user_id, params) do
    Api.put(client, "/users/#{user_id}/guides/engagements/reset", params)
  end

  ##
  # Preference center
  ##

  @doc """
  Returns the preference center configuration for the user.
  """
  @spec get_preference_center_config(Client.t(), String.t()) :: Api.response()
  def get_preference_center_config(client, user_id) do
    Api.get(client, "/users/#{user_id}/preference_center/config")
  end

  @doc """
  Generates a signed URL to the hosted preference center for the user.
  """
  @spec generate_preference_center_signed_url(Client.t(), String.t()) :: Api.response()
  def generate_preference_center_signed_url(client, user_id) do
    Api.post(client, "/users/#{user_id}/preference_center/signed_url", %{})
  end

  defp build_setting_param(setting) when is_map(setting), do: setting
  defp build_setting_param(setting), do: %{subscribed: setting}
end
