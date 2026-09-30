defmodule Knock.Providers.MsTeamsTest do
  use Knock.Case, async: true

  alias Knock.Providers.MsTeams

  @tenant_object ~s({"collection":"projects","object_id":"p1"})

  test "check_auth/3", %{client: client} do
    {_, req} = capture_request(fn -> MsTeams.check_auth(client, "ch_1", @tenant_object) end)

    assert {req.method, req.path} == {:get, "/providers/ms-teams/ch_1/auth_check"}
    assert req.query == "ms_teams_tenant_object=" <> @tenant_object
  end

  test "list_teams/4 encodes query options", %{client: client} do
    {_, req} =
      capture_request(fn ->
        MsTeams.list_teams(client, "ch_1", @tenant_object,
          query_options: %{"$top" => 10, "$skiptoken" => "x"}
        )
      end)

    assert {req.method, req.path} == {:get, "/providers/ms-teams/ch_1/teams"}

    assert req.query ==
             q(
               "ms_teams_tenant_object=#{@tenant_object}&" <>
                 "query_options[$top]=10&query_options[$skiptoken]=x"
             )
  end

  test "list_channels/5 sends the team id", %{client: client} do
    {_, req} =
      capture_request(fn -> MsTeams.list_channels(client, "ch_1", @tenant_object, "team_1") end)

    assert {req.method, req.path} == {:get, "/providers/ms-teams/ch_1/channels"}
    assert req.query == q("ms_teams_tenant_object=#{@tenant_object}&team_id=team_1")
  end

  test "revoke_access/3", %{client: client} do
    {_, req} = capture_request(fn -> MsTeams.revoke_access(client, "ch_1", @tenant_object) end)

    assert {req.method, req.path, req.body} ==
             {:put, "/providers/ms-teams/ch_1/revoke_access", %{}}

    assert req.query == "ms_teams_tenant_object=" <> @tenant_object
  end
end
