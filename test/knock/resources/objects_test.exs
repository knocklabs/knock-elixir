defmodule Knock.ObjectsTest do
  use Knock.Case, async: true

  alias Knock.Objects

  test "build_ref/2" do
    assert Objects.build_ref("projects", "p1") == %{id: "p1", collection: "projects"}
  end

  describe "core" do
    test "list/3", %{client: client} do
      {_, req} = capture_request(fn -> Objects.list(client, "projects", page_size: 5) end)
      assert {req.method, req.path, req.query} == {:get, "/objects/projects", "page_size=5"}
    end

    test "get/set/delete", %{client: client} do
      {_, req} = capture_request(fn -> Objects.get(client, "projects", "p1") end)
      assert {req.method, req.path} == {:get, "/objects/projects/p1"}

      {_, req} = capture_request(fn -> Objects.set(client, "projects", "p1", %{name: "P"}) end)
      assert {req.method, req.path, req.body} == {:put, "/objects/projects/p1", %{"name" => "P"}}

      {_, req} = capture_request(fn -> Objects.delete(client, "projects", "p1") end)
      assert {req.method, req.path} == {:delete, "/objects/projects/p1"}
    end
  end

  describe "bulk" do
    test "bulk_set/3", %{client: client} do
      {_, req} = capture_request(fn -> Objects.bulk_set(client, "projects", [%{id: "p1"}]) end)

      assert {req.method, req.path, req.body} ==
               {:post, "/objects/projects/bulk/set", %{"objects" => [%{"id" => "p1"}]}}
    end

    test "bulk_delete/3", %{client: client} do
      {_, req} = capture_request(fn -> Objects.bulk_delete(client, "projects", ["p1"]) end)

      assert {req.method, req.path, req.body} ==
               {:post, "/objects/projects/bulk/delete", %{"object_ids" => ["p1"]}}
    end

    test "bulk_add_subscriptions/3", %{client: client} do
      subscriptions = [%{id: "p1", recipients: ["u1"]}]

      {_, req} =
        capture_request(fn ->
          Objects.bulk_add_subscriptions(client, "projects", subscriptions)
        end)

      assert {req.method, req.path} == {:post, "/objects/projects/bulk/subscriptions/add"}
      assert req.body == %{"subscriptions" => [%{"id" => "p1", "recipients" => ["u1"]}]}
    end
  end

  describe "bulk subscriptions delete" do
    test "bulk_delete_subscriptions/3", %{client: client} do
      subscriptions = [%{id: "p1", recipients: ["u1"]}]

      {_, req} =
        capture_request(fn ->
          Objects.bulk_delete_subscriptions(client, "projects", subscriptions)
        end)

      assert {req.method, req.path} == {:post, "/objects/projects/bulk/subscriptions/delete"}
      assert req.body == %{"subscriptions" => [%{"id" => "p1", "recipients" => ["u1"]}]}
    end
  end

  describe "channel data" do
    test "get/set/unset channel data", %{client: client} do
      path = "/objects/projects/p1/channel_data/ch_1"

      {_, req} =
        capture_request(fn -> Objects.get_channel_data(client, "projects", "p1", "ch_1") end)

      assert {req.method, req.path} == {:get, path}

      {_, req} =
        capture_request(fn ->
          Objects.set_channel_data(client, "projects", "p1", "ch_1", %{token: "t"})
        end)

      assert {req.method, req.path, req.body} == {:put, path, %{"data" => %{"token" => "t"}}}

      {_, req} =
        capture_request(fn -> Objects.unset_channel_data(client, "projects", "p1", "ch_1") end)

      assert {req.method, req.path} == {:delete, path}
    end
  end

  describe "messages and schedules" do
    test "get_messages/4", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Objects.get_messages(client, "projects", "p1", trigger_data: %{"a" => 1})
        end)

      assert {req.method, req.path} == {:get, "/objects/projects/p1/messages"}
      assert req.query == ~s(trigger_data={"a":1})
    end

    test "get_schedules/4", %{client: client} do
      {_, req} =
        capture_request(fn -> Objects.get_schedules(client, "projects", "p1", tenant: "t") end)

      assert {req.method, req.path, req.query} ==
               {:get, "/objects/projects/p1/schedules", "tenant=t"}
    end
  end

  describe "subscriptions" do
    test "list_subscriptions/4 with user id recipients", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Objects.list_subscriptions(client, "projects", "p1", recipients: ["u1", "u2"])
        end)

      assert {req.method, req.path} == {:get, "/objects/projects/p1/subscriptions"}
      assert req.query == "recipients[]=u1&recipients[]=u2"
    end

    test "list_subscriptions/4 with object reference recipients", %{client: client} do
      {result, req} =
        capture_request(fn ->
          Objects.list_subscriptions(client, "projects", "p1",
            recipients: [%{id: "u1", collection: "users"}, %{id: "t1", collection: "teams"}]
          )
        end)

      assert {:ok, _} = result

      assert req.query ==
               q(
                 "recipients[0][collection]=users&recipients[0][id]=u1&" <>
                   "recipients[1][collection]=teams&recipients[1][id]=t1"
               )
    end

    test "get_subscriptions/4 sets recipient mode", %{client: client} do
      {_, req} = capture_request(fn -> Objects.get_subscriptions(client, "projects", "p1") end)

      assert {req.method, req.path, req.query} ==
               {:get, "/objects/projects/p1/subscriptions", "mode=recipient"}
    end

    test "add_subscriptions/4", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Objects.add_subscriptions(client, "projects", "p1", %{recipients: ["u1"]})
        end)

      assert {req.method, req.path, req.body} ==
               {:post, "/objects/projects/p1/subscriptions", %{"recipients" => ["u1"]}}
    end

    test "delete_subscriptions/4 accepts string-keyed params", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Objects.delete_subscriptions(client, "projects", "p1", %{"recipients" => ["u1"]})
        end)

      assert req.body == %{"recipients" => ["u1"]}
    end

    test "delete_subscriptions/4 only sends recipients", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Objects.delete_subscriptions(client, "projects", "p1", %{recipients: ["u1"], other: 1})
        end)

      assert req.body == %{"recipients" => ["u1"]}
    end

    test "delete_subscriptions/4 sends a JSON body", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Objects.delete_subscriptions(client, "projects", "p1", %{recipients: ["u1"]})
        end)

      assert {req.method, req.path, req.body} ==
               {:delete, "/objects/projects/p1/subscriptions", %{"recipients" => ["u1"]}}
    end
  end

  describe "preferences" do
    test "get_all/get/set preferences", %{client: client} do
      {_, req} = capture_request(fn -> Objects.get_all_preferences(client, "projects", "p1") end)
      assert {req.method, req.path} == {:get, "/objects/projects/p1/preferences"}

      {_, req} = capture_request(fn -> Objects.get_preferences(client, "projects", "p1") end)
      assert {req.method, req.path} == {:get, "/objects/projects/p1/preferences/default"}

      {_, req} =
        capture_request(fn ->
          Objects.set_preferences(client, "projects", "p1", %{workflows: %{}},
            preference_set: "x"
          )
        end)

      assert {req.method, req.path, req.body} ==
               {:put, "/objects/projects/p1/preferences/x", %{"workflows" => %{}}}
    end

    test "unset_preferences/4", %{client: client} do
      {_, req} = capture_request(fn -> Objects.unset_preferences(client, "projects", "p1") end)
      assert {req.method, req.path} == {:delete, "/objects/projects/p1/preferences/default"}

      {_, req} =
        capture_request(fn ->
          Objects.unset_preferences(client, "projects", "p1", preference_set: "x")
        end)

      assert req.path == "/objects/projects/p1/preferences/x"
    end

    test "granular preference setters", %{client: client} do
      base = "/objects/projects/p1/preferences/default"

      {_, req} =
        capture_request(fn ->
          Objects.set_channel_types_preferences(client, "projects", "p1", %{sms: false})
        end)

      assert {req.path, req.body} == {base <> "/channel_types", %{"sms" => false}}

      {_, req} =
        capture_request(fn ->
          Objects.set_channel_type_preferences(client, "projects", "p1", "sms", true)
        end)

      assert {req.path, req.body} == {base <> "/channel_types/sms", %{"subscribed" => true}}

      {_, req} =
        capture_request(fn ->
          Objects.set_workflows_preferences(client, "projects", "p1", %{"wf" => true})
        end)

      assert {req.path, req.body} == {base <> "/workflows", %{"wf" => true}}

      {_, req} =
        capture_request(fn ->
          Objects.set_workflow_preferences(client, "projects", "p1", "wf", false)
        end)

      assert {req.path, req.body} == {base <> "/workflows/wf", %{"subscribed" => false}}

      {_, req} =
        capture_request(fn ->
          Objects.set_categories_preferences(client, "projects", "p1", %{"cat" => true})
        end)

      assert {req.path, req.body} == {base <> "/categories", %{"cat" => true}}

      {_, req} =
        capture_request(fn ->
          Objects.set_category_preferences(client, "projects", "p1", "cat", %{
            channel_types: %{email: false}
          })
        end)

      assert {req.path, req.body} ==
               {base <> "/categories/cat", %{"channel_types" => %{"email" => false}}}
    end
  end
end
