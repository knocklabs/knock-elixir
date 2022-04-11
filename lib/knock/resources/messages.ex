defmodule Knock.Messages do
  @moduledoc """
  Knock resources for accessing messages
  """
  alias Knock.Api
  alias Knock.Client

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
  # - page_size: specify size of the page to be returned by the api. Top limit: 50
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
  # - page_size: specify size of the page to be returned by the api. Top limit: 50
  # - after:  after cursor for pagination
  # - before: before cursor for pagination
  """
  @spec get_events(Client.t(), String.t(), Keyword.t()) :: Api.response()
  def get_events(client, message_id, options \\ []) do
    Api.get(client, "/messages/#{message_id}/events", query: options)
  end
end
