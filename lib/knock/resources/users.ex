defmodule Knock.Users do
  @moduledoc """
  Knock resources for accessing users
  """
  alias Knock.Api
  alias Knock.Client

  @doc """
  Returns information about the user from the `user_id` given.
  """
  @spec get_user(Client.t(), String.t()) :: Api.response()
  def get_user(client, user_id) do
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
end
