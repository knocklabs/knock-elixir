defmodule Knock.Messages do
  @moduledoc """
  Knock resources for accessing messages
  """
  import Knock.ResourceHelpers, only: [maybe_json_encode_param: 3]

  alias Knock.Api
  alias Knock.Client

  @doc """
  Returns paginated messages for the provided environment

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
  @spec list(Client.t(), Keyword.t()) :: Api.response()
  def list(client, options \\ []) do
    options = maybe_json_encode_param(options, :trigger_data, client.json_client)

    Api.get(client, "/messages", query: options)
  end

  @doc """
  Returns information about the message.
  """
  @spec get(Client.t(), String.t()) :: Api.response()
  def get(client, message_id) do
    Api.get(client, "/messages/#{message_id}")
  end

  @doc """
  Sets status of message: seen, read, archived, interacted

  Optionally accepts a map of params to send with the request, e.g.
  `%{metadata: %{...}}` when marking a message as interacted.
  """
  @spec set_status(Client.t(), String.t(), String.t(), map()) :: Api.response()
  def set_status(client, message_id, status, params \\ %{}) do
    Api.put(client, "/messages/#{message_id}/#{status}", params)
  end

  @doc """
  Unsets status of message. Accepts either the status to unset (seen, read, archived) or its
  inverse (unseen, unread, unarchived).
  """
  @spec unset_status(Client.t(), String.t(), String.t()) :: Api.response()
  def unset_status(client, message_id, status) do
    Api.delete(client, "/messages/#{message_id}/#{status}")
  end

  @doc """
  Batch update messages statuses: seen, read, interacted, archived, unseen, unread,
  unarchived

  Optionally accepts a map of params to send with the request, e.g.
  `%{metadata: %{...}}` when marking messages as interacted.
  """
  @spec batch_set_status(Client.t(), [String.t()], String.t(), map()) :: Api.response()
  def batch_set_status(client, message_ids, status, params \\ %{}) do
    Api.post(client, "/messages/batch/#{status}", Map.put(params, :message_ids, message_ids))
  end

  @doc """
  Returns information about the message content.
  """
  @spec get_content(Client.t(), String.t()) :: Api.response()
  def get_content(client, message_id) do
    Api.get(client, "/messages/#{message_id}/content")
  end

  @doc """
  Returns information about the message content in batches.
  """
  @spec batch_get_content(Client.t(), [String.t()]) :: Api.response()
  def batch_get_content(client, message_ids) do
    Api.get(client, "/messages/batch/content", query: [message_ids: message_ids])
  end

  @doc """
  Returns a paginated response with message's activities.

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  * `:trigger_data` - filter activities by trigger payload data, as a map or a JSON-encoded
    string
  """
  @spec get_activities(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_activities(client, message_id, options \\ []) do
    options = maybe_json_encode_param(options, :trigger_data, client.json_client)

    Api.get(client, "/messages/#{message_id}/activities", query: options)
  end

  @doc """
  Returns a paginated response with message's events.

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  """
  @spec get_events(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_events(client, message_id, options \\ []) do
    Api.get(client, "/messages/#{message_id}/events", query: options)
  end

  @doc """
  Returns a paginated response with message's delivery logs.

  ## Available optional parameters:

  * `:page_size` - specify size of the page to be returned by the api. (max limit: 50)
  * `:after` - after cursor for pagination
  * `:before` - before cursor for pagination
  """
  @spec get_delivery_logs(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_delivery_logs(client, message_id, options \\ []) do
    Api.get(client, "/messages/#{message_id}/delivery_logs", query: options)
  end
end
