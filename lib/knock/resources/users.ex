defmodule Knock.Users do
  @moduledoc """
  Knock resources for accessing users
  """
  alias Knock.Api

  @doc """
  Returns information about the user from the `user_id` given.
  """
  @spec get_user(Knock.Client.t(), String.t()) :: Api.response()
  def get_user(client, user_id) do
    Api.get(client, "/users/#{user_id}")
  end

  @doc """
  Sets the given properties on the user specified via the `user_id`. Will perform
  an upsert of the user.
  """
  @spec identify(Knock.Client.t(), String.t(), map()) :: Api.response()
  def identify(client, user_id, properties) do
    Api.put(client, "/users/#{user_id}", properties)
  end

  @doc """
  Issues a delete request against the user specified
  """
  def delete(client, user_id) do
    Api.delete(client, "/users/#{user_id}")
  end
end
