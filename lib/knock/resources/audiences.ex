defmodule Knock.Audiences do
  @moduledoc """
  Knock resources for accessing audiences
  """
  alias Knock.Api
  alias Knock.Client

  @doc """
  Adds members to the audience with the given key. Accepts up to 1,000 members per request.

  Each member should have the properties:

  - user: a map with the `id` of the user to add
  - tenant (optional): the tenant id to add the user to the audience for

  ## Available optional parameters:

  * `:create_audience` - create the audience if it doesn't exist
  """
  @spec add_members(Client.t(), String.t(), [map()], Keyword.t()) :: Api.response()
  def add_members(client, key, members, options \\ []) do
    Api.post(client, "/audiences/#{key}/members", %{members: members}, query: options)
  end

  @doc """
  Returns the members of the audience with the given key.
  """
  @spec list_members(Client.t(), String.t()) :: Api.response()
  def list_members(client, key) do
    Api.get(client, "/audiences/#{key}/members")
  end

  @doc """
  Removes members from the audience with the given key.
  """
  @spec remove_members(Client.t(), String.t(), [map()]) :: Api.response()
  def remove_members(client, key, members) do
    Api.delete(client, "/audiences/#{key}/members", body: %{members: members})
  end
end
