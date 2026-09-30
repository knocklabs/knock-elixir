defmodule Knock.Providers.SlackTest do
  use Knock.Case, async: true

  alias Knock.Providers.Slack

  @token_object ~s({"collection":"projects","object_id":"p1"})

  test "check_auth/3 passes a JSON-encoded token object through", %{client: client} do
    {_, req} = capture_request(fn -> Slack.check_auth(client, "ch_1", @token_object) end)

    assert {req.method, req.path} == {:get, "/providers/slack/ch_1/auth_check"}
    assert req.query == "access_token_object=" <> @token_object
  end

  test "check_auth/3 JSON-encodes a map token object", %{client: client} do
    {_, req} =
      capture_request(fn ->
        Slack.check_auth(client, "ch_1", %{"collection" => "projects", "object_id" => "p1"})
      end)

    assert req.query == "access_token_object=" <> @token_object
  end

  test "list_channels/4 encodes query options", %{client: client} do
    {_, req} =
      capture_request(fn ->
        Slack.list_channels(client, "ch_1", @token_object,
          query_options: %{cursor: "abc", limit: 100}
        )
      end)

    assert {req.method, req.path} == {:get, "/providers/slack/ch_1/channels"}

    assert req.query ==
             q(
               "access_token_object=#{@token_object}&" <>
                 "query_options[cursor]=abc&query_options[limit]=100"
             )
  end

  test "revoke_access/3", %{client: client} do
    {_, req} = capture_request(fn -> Slack.revoke_access(client, "ch_1", @token_object) end)

    assert {req.method, req.path, req.body} == {:put, "/providers/slack/ch_1/revoke_access", %{}}
    assert req.query == "access_token_object=" <> @token_object
  end
end
