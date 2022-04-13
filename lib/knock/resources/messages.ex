defmodule Knock.Messages do
  @moduledoc """
  Knock resources for accessing messages
  """
  alias Knock.Api
  alias Knock.Client

  @doc """
  Returns paginated messages for the provided environment

  # Available optional parameters:
  #
  # - page_size: specify size of the page to be returned by the api. (max limit: 50)
  # - after:  after cursor for pagination
  # - before: before cursor for pagination
  # - status: list of statuses to filter messages with
  # - tenant: tenant_id to filter messages with
  # - channel_id: channel_id to filter messages with
  # - source: workflow key to filter messages with

  """
  @spec list(Client.t(), Keyword.t()) :: Api.response()
  def list(client, options \\ []) do
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
  Returns information about the message content.
  """
  @spec get_content(Client.t(), String.t()) :: Api.response()
  def get_content(client, message_id) do
    Api.get(client, "/messages/#{message_id}/content")
  end

  @doc """
  Returns a paginated response with message's activities.

  # Available optional parameters:
  #
  # - page_size: specify size of the page to be returned by the api. (max limit: 50)
  # - after:  after cursor for pagination
  # - before: before cursor for pagination
  """
  @spec get_activities(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_activities(client, message_id, options \\ []) do
    Api.get(client, "/messages/#{message_id}/activities", query: options)
  end

  @doc """
  Returns a paginated response with message's events.

  # Available optional parameters:
  #
  # - page_size: specify size of the page to be returned by the api. (max limit: 50)
  # - after:  after cursor for pagination
  # - before: before cursor for pagination
  """
  @spec get_events(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_events(client, message_id, options \\ []) do
    Api.get(client, "/messages/#{message_id}/events", query: options)
  end
end
