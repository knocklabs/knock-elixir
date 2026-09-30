defmodule Knock.Providers.MsTeams do
  @moduledoc """
  Knock resources for interacting with a Microsoft Teams channel's provider.

  Functions take a `ms_teams_tenant_object`, which references where the Microsoft Teams tenant
  id is stored: a JSON-encoded string such as `~s({"collection":"projects","object_id":"p1"})`,
  or a map that will be JSON-encoded with the client's JSON library.
  """
  import Knock.ResourceHelpers, only: [json_query_param: 3]

  alias Knock.Api
  alias Knock.Client

  @doc """
  Checks whether the Microsoft Teams tenant referenced by `ms_teams_tenant_object` has been
  authorized.
  """
  @spec check_auth(Client.t(), String.t(), map() | String.t()) :: Api.response()
  def check_auth(client, channel_id, ms_teams_tenant_object) do
    Api.get(client, "/providers/ms-teams/#{channel_id}/auth_check",
      query: json_query_param(client, :ms_teams_tenant_object, ms_teams_tenant_object)
    )
  end

  @doc """
  Returns the teams available in the Microsoft Teams tenant.

  ## Available optional parameters:

  * `:query_options` - map of Microsoft Graph query options: `"$filter"`, `"$select"`,
    `"$top"` and `"$skiptoken"`
  """
  @spec list_teams(Client.t(), String.t(), map() | String.t(), Keyword.t()) :: Api.response()
  def list_teams(client, channel_id, ms_teams_tenant_object, options \\ []) do
    Api.get(client, "/providers/ms-teams/#{channel_id}/teams",
      query: json_query_param(client, :ms_teams_tenant_object, ms_teams_tenant_object) ++ options
    )
  end

  @doc """
  Returns the channels of the given team in the Microsoft Teams tenant.

  ## Available optional parameters:

  * `:query_options` - map of Microsoft Graph query options: `"$filter"` and `"$select"`
  """
  @spec list_channels(Client.t(), String.t(), map() | String.t(), String.t(), Keyword.t()) ::
          Api.response()
  def list_channels(client, channel_id, ms_teams_tenant_object, team_id, options \\ []) do
    Api.get(client, "/providers/ms-teams/#{channel_id}/channels",
      query:
        json_query_param(client, :ms_teams_tenant_object, ms_teams_tenant_object) ++
          [team_id: team_id] ++ options
    )
  end

  @doc """
  Revokes access to the Microsoft Teams tenant referenced by `ms_teams_tenant_object`.
  """
  @spec revoke_access(Client.t(), String.t(), map() | String.t()) :: Api.response()
  def revoke_access(client, channel_id, ms_teams_tenant_object) do
    Api.put(client, "/providers/ms-teams/#{channel_id}/revoke_access", %{},
      query: json_query_param(client, :ms_teams_tenant_object, ms_teams_tenant_object)
    )
  end
end
