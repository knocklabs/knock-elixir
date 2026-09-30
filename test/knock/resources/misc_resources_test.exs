defmodule Knock.MiscResourcesTest do
  use Knock.Case, async: true

  test "BulkOperations.get/2", %{client: client} do
    {_, req} = capture_request(fn -> Knock.BulkOperations.get(client, "op_1") end)
    assert {req.method, req.path} == {:get, "/bulk_operations/op_1"}
  end

  test "Channels.bulk_set_messages_status/4", %{client: client} do
    {_, req} =
      capture_request(fn ->
        Knock.Channels.bulk_set_messages_status(client, "ch_1", "archive", %{
          recipient_ids: ["u1"]
        })
      end)

    assert {req.method, req.path, req.body} ==
             {:post, "/channels/ch_1/messages/bulk/archive", %{"recipient_ids" => ["u1"]}}
  end

  test "Channels.bulk_set_messages_status/4 encodes a trigger_data map", %{client: client} do
    {_, req} =
      capture_request(fn ->
        Knock.Channels.bulk_set_messages_status(client, "ch_1", "delete", %{
          trigger_data: %{"a" => 1},
          workflows: ["wf"]
        })
      end)

    assert req.body == %{"trigger_data" => ~s({"a":1}), "workflows" => ["wf"]}

    {_, req} =
      capture_request(fn ->
        Knock.Channels.bulk_set_messages_status(client, "ch_1", "delete", %{
          "trigger_data" => ~s({"a":1})
        })
      end)

    assert req.body == %{"trigger_data" => ~s({"a":1})}
  end

  test "deprecated Knock.Preferences delegates to Users", %{client: client} do
    {_, req} = capture_request(fn -> apply(Knock.Preferences, :get, [client, "u1"]) end)
    assert {req.method, req.path} == {:get, "/users/u1/preferences/default"}

    {_, req} =
      capture_request(fn ->
        apply(Knock.Preferences, :set_channel_type, [client, "u1", "email", true])
      end)

    assert {req.method, req.path} == {:put, "/users/u1/preferences/default/channel_types/email"}
  end
end
