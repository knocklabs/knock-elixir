defmodule Knock.Channels do
  @moduledoc """
  Knock resources for accessing channels
  """
  import Knock.ResourceHelpers, only: [json_encode_value: 3]

  alias Knock.Api
  alias Knock.Client

  @doc """
  Bulk updates channel's messages with provided action: seen, unseen, read, unread, archived,
  unarchived, interacted, archive, unarchive or delete. Note that `delete` permanently deletes
  the matching messages.

  Supports filtering messages to be updated with the following options:

  - tenants: Scope messages to the list of tenant ids
  - has_tenant: Scope to where either do or do not have a tenant present
  - recipient_ids: Scope messages to the list of recipient ids
  - engagement_status: Scope messages by engagements status: read, unread, seen,
    unseen, archived, unarchived, interacted, link_clicked
  - archived: scopes to a particular type of archival status, one of
    exclude, include, only
  - delivery_status: scope to only messages by delivery status, these can be the following:
    queued, sent, undelivered, delivery_attempted, delivered
  - older_than: scope to only messages that were created before provided date
  - newer_than: scope to only messages that were created after provided date
  - workflows: scope messages to the list of workflow keys
  - trigger_data: scope messages by trigger payload, as a JSON-encoded string or a map
  """
  @spec bulk_set_messages_status(Client.t(), String.t(), String.t(), map()) :: Api.response()
  def bulk_set_messages_status(client, channel_id, action, filtering_options \\ %{}) do
    Api.post(
      client,
      "/channels/#{channel_id}/messages/bulk/#{action}",
      encode_trigger_data(filtering_options, client.json_client)
    )
  end

  defp encode_trigger_data(filtering_options, json_client) do
    Enum.into(filtering_options, %{}, fn
      {key, value} when key in [:trigger_data, "trigger_data"] ->
        {key, json_encode_value(value, :trigger_data, json_client)}

      pair ->
        pair
    end)
  end
end
