defmodule Knock.Channels do
  @moduledoc """
  Knock resources for accessing channels
  """

  alias Knock.Api
  alias Knock.Client

  @doc """
  Bulk updates channel's messages with provided action.
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
  """
  @spec bulk_set_messages_status(Client.t(), String.t(), String.t(), map()) :: Api.response()
  def bulk_set_messages_status(client, channel_id, action, filtering_options \\ %{}) do
    Api.post(client, "/channels/#{channel_id}/messages/bulk/#{action}", filtering_options)
  end
end
