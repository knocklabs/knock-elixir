defmodule Knock.MessagesTest do
  use Knock.Case, async: true

  alias Knock.Messages

  test "list/2", %{client: client} do
    {_, req} =
      capture_request(fn ->
        Messages.list(client,
          engagement_status: ["seen"],
          trigger_data: %{"a" => 1},
          page_size: 10
        )
      end)

    assert {req.method, req.path} == {:get, "/messages"}
    assert req.query == q(~s(engagement_status[]=seen&trigger_data={"a":1}&page_size=10))
  end

  test "get/2", %{client: client} do
    {_, req} = capture_request(fn -> Messages.get(client, "m1") end)
    assert {req.method, req.path} == {:get, "/messages/m1"}
  end

  test "set_status/3", %{client: client} do
    for status <- ["seen", "read", "archived", "interacted"] do
      {_, req} = capture_request(fn -> Messages.set_status(client, "m1", status) end)
      assert {req.method, req.path, req.body} == {:put, "/messages/m1/#{status}", %{}}
    end
  end

  test "unset_status/3", %{client: client} do
    for status <- ["seen", "read", "archived", "unseen", "unread", "unarchived"] do
      {_, req} = capture_request(fn -> Messages.unset_status(client, "m1", status) end)
      assert {req.method, req.path} == {:delete, "/messages/m1/#{status}"}
    end
  end

  test "batch_set_status/3", %{client: client} do
    {_, req} = capture_request(fn -> Messages.batch_set_status(client, ["m1", "m2"], "read") end)

    assert {req.method, req.path, req.body} ==
             {:post, "/messages/batch/read", %{"message_ids" => ["m1", "m2"]}}
  end

  test "get_content/2 and batch_get_content/2", %{client: client} do
    {_, req} = capture_request(fn -> Messages.get_content(client, "m1") end)
    assert {req.method, req.path} == {:get, "/messages/m1/content"}

    {_, req} = capture_request(fn -> Messages.batch_get_content(client, ["m1", "m2"]) end)

    assert {req.method, req.path, req.query} ==
             {:get, "/messages/batch/content", "message_ids[]=m1&message_ids[]=m2"}
  end

  test "get_activities/3 and get_events/3", %{client: client} do
    {_, req} =
      capture_request(fn -> Messages.get_activities(client, "m1", trigger_data: %{"a" => 1}) end)

    assert {req.method, req.path, req.query} ==
             {:get, "/messages/m1/activities", ~s(trigger_data={"a":1})}

    {_, req} = capture_request(fn -> Messages.get_events(client, "m1", after: "c") end)
    assert {req.method, req.path, req.query} == {:get, "/messages/m1/events", "after=c"}
  end
end
