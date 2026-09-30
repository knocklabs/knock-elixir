defmodule Knock.Providers.Slack do
  @moduledoc """
  Knock resources for interacting with a Slack channel's provider.

  Functions take an `access_token_object`, which references where the Slack access token is
  stored: a JSON-encoded string such as `~s({"collection":"projects","object_id":"p1"})`, or a
  map that will be JSON-encoded with the client's JSON library.
  """
  import Knock.ResourceHelpers, only: [json_query_param: 3]

  alias Knock.Api
  alias Knock.Client

  @doc """
  Checks whether the Slack access token referenced by `access_token_object` is valid.
  """
  @spec check_auth(Client.t(), String.t(), map() | String.t()) :: Api.response()
  def check_auth(client, channel_id, access_token_object) do
    Api.get(client, "/providers/slack/#{channel_id}/auth_check",
      query: json_query_param(client, :access_token_object, access_token_object)
    )
  end

  @doc """
  Returns the Slack channels available to the access token referenced by
  `access_token_object`.

  ## Available optional parameters:

  * `:query_options` - map of Slack query options: `:cursor`, `:limit`, `:exclude_archived`,
    `:types` and `:team_id`
  """
  @spec list_channels(Client.t(), String.t(), map() | String.t(), Keyword.t()) ::
          Api.response()
  def list_channels(client, channel_id, access_token_object, options \\ []) do
    Api.get(client, "/providers/slack/#{channel_id}/channels",
      query: json_query_param(client, :access_token_object, access_token_object) ++ options
    )
  end

  @doc """
  Revokes access to Slack for the access token referenced by `access_token_object`.
  """
  @spec revoke_access(Client.t(), String.t(), map() | String.t()) :: Api.response()
  def revoke_access(client, channel_id, access_token_object) do
    Api.put(client, "/providers/slack/#{channel_id}/revoke_access", %{},
      query: json_query_param(client, :access_token_object, access_token_object)
    )
  end
end
