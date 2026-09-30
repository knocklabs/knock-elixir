defmodule Knock.UsersTest do
  use Knock.Case, async: true

  alias Knock.Users

  describe "core" do
    test "list/2", %{client: client} do
      {{:ok, %Knock.Response{status: 200}}, req} =
        capture_request(fn -> Users.list(client, page_size: 10, include: ["preferences"]) end)

      assert req.method == :get
      assert req.path == "/users"
      assert req.query == q("page_size=10&include[]=preferences")
    end

    test "get/2 and the deprecated get_user/2", %{client: client} do
      {_, req} = capture_request(fn -> Users.get(client, "u1") end)
      assert {req.method, req.path} == {:get, "/users/u1"}

      {_, req} = capture_request(fn -> apply(Users, :get_user, [client, "u1"]) end)
      assert {req.method, req.path} == {:get, "/users/u1"}
    end

    test "identify/3", %{client: client} do
      {_, req} = capture_request(fn -> Users.identify(client, "u1", %{name: "Jane"}) end)

      assert {req.method, req.path, req.body} == {:put, "/users/u1", %{"name" => "Jane"}}
    end

    test "delete/2", %{client: client} do
      {_, req} = capture_request(fn -> Users.delete(client, "u1") end)
      assert {req.method, req.path} == {:delete, "/users/u1"}
    end

    test "merge/3", %{client: client} do
      {_, req} = capture_request(fn -> Users.merge(client, "u1", "u2") end)

      assert {req.method, req.path, req.body} ==
               {:post, "/users/u1/merge", %{"from_user_id" => "u2"}}
    end

    test "returns an error tuple for non-2xx responses", %{client: client} do
      {result, _} =
        capture_request(fn -> Users.get(client, "missing") end,
          status: 404,
          body: %{"code" => "resource_missing"}
        )

      assert {:error, %Knock.Response{status: 404, body: %{"code" => "resource_missing"}}} =
               result
    end
  end

  describe "feeds" do
    test "get_feed/4 encodes trigger_data and passes filters as query", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Users.get_feed(client, "u1", "feed_1",
            status: "unread",
            trigger_data: %{"foo" => "bar"}
          )
        end)

      assert req.method == :get
      assert req.path == "/users/u1/feeds/feed_1"

      assert req.query == q(~s(status=unread&trigger_data={"foo":"bar"}))
    end
  end

  describe "query encoding" do
    test "get_feed/4 encodes nested inserted_at filters", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Users.get_feed(client, "u1", "feed_1", inserted_at: %{gt: "2024-01-01T00:00:00Z"})
        end)

      assert req.query == "inserted_at[gt]=2024-01-01T00:00:00Z"
    end

    test "get_messages/3 passes a pre-encoded trigger_data string through", %{client: client} do
      {_, req} =
        capture_request(fn -> Users.get_messages(client, "u1", trigger_data: ~s({"a":1})) end)

      assert req.query == ~s(trigger_data={"a":1})
    end

    test "get_subscriptions/3 encodes object references with indexed keys", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Users.get_subscriptions(client, "u1", objects: [%{id: "p1", collection: "projects"}])
        end)

      assert req.query == q("objects[0][collection]=projects&objects[0][id]=p1")
    end
  end

  describe "feed settings" do
    test "get_feed_settings/3", %{client: client} do
      {_, req} = capture_request(fn -> Users.get_feed_settings(client, "u1", "feed_1") end)
      assert {req.method, req.path} == {:get, "/users/u1/feeds/feed_1/settings"}
    end
  end

  describe "bulk" do
    test "bulk_identify/2", %{client: client} do
      {_, req} = capture_request(fn -> Users.bulk_identify(client, [%{id: "u1"}]) end)

      assert {req.method, req.path, req.body} ==
               {:post, "/users/bulk/identify", %{"users" => [%{"id" => "u1"}]}}
    end

    test "bulk_delete/2", %{client: client} do
      {_, req} = capture_request(fn -> Users.bulk_delete(client, ["u1", "u2"]) end)

      assert {req.method, req.path, req.body} ==
               {:post, "/users/bulk/delete", %{"user_ids" => ["u1", "u2"]}}
    end

    test "bulk_set_preferences/4", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Users.bulk_set_preferences(client, ["u1"], %{"channel_types" => %{"email" => true}})
        end)

      assert req.path == "/users/bulk/preferences"

      assert req.body == %{
               "user_ids" => ["u1"],
               "preferences" => %{"id" => "default", "channel_types" => %{"email" => true}}
             }
    end
  end

  describe "channel data" do
    test "get/set/unset channel data", %{client: client} do
      {_, req} = capture_request(fn -> Users.get_channel_data(client, "u1", "ch_1") end)
      assert {req.method, req.path} == {:get, "/users/u1/channel_data/ch_1"}

      {_, req} =
        capture_request(fn -> Users.set_channel_data(client, "u1", "ch_1", %{tokens: ["t"]}) end)

      assert {req.method, req.path, req.body} ==
               {:put, "/users/u1/channel_data/ch_1", %{"data" => %{"tokens" => ["t"]}}}

      {_, req} = capture_request(fn -> Users.unset_channel_data(client, "u1", "ch_1") end)
      assert {req.method, req.path} == {:delete, "/users/u1/channel_data/ch_1"}
    end
  end

  describe "preferences" do
    test "get_all_preferences/2", %{client: client} do
      {_, req} = capture_request(fn -> Users.get_all_preferences(client, "u1") end)
      assert {req.method, req.path} == {:get, "/users/u1/preferences"}
    end

    test "get_preferences/3 defaults to the default preference set", %{client: client} do
      {_, req} = capture_request(fn -> Users.get_preferences(client, "u1") end)
      assert {req.method, req.path, req.query} == {:get, "/users/u1/preferences/default", nil}

      {_, req} =
        capture_request(fn -> Users.get_preferences(client, "u1", preference_set: "other") end)

      assert req.path == "/users/u1/preferences/other"
    end

    test "get_preferences/3 sends the tenant as a query param", %{client: client} do
      {_, req} = capture_request(fn -> Users.get_preferences(client, "u1", tenant: "t1") end)
      assert {req.path, req.query} == {"/users/u1/preferences/default", "tenant=t1"}
    end

    test "unset_preferences/3", %{client: client} do
      {_, req} = capture_request(fn -> Users.unset_preferences(client, "u1") end)
      assert {req.method, req.path} == {:delete, "/users/u1/preferences/default"}

      {_, req} =
        capture_request(fn -> Users.unset_preferences(client, "u1", preference_set: "other") end)

      assert req.path == "/users/u1/preferences/other"
    end

    test "set_preferences/4", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Users.set_preferences(client, "u1", %{"__persistence_strategy__" => "merge"})
        end)

      assert {req.method, req.path, req.body} ==
               {:put, "/users/u1/preferences/default", %{"__persistence_strategy__" => "merge"}}
    end

    test "granular preference setters", %{client: client} do
      base = "/users/u1/preferences/default"

      {_, req} =
        capture_request(fn ->
          Users.set_channel_types_preferences(client, "u1", %{email: true})
        end)

      assert {req.method, req.path, req.body} ==
               {:put, base <> "/channel_types", %{"email" => true}}

      {_, req} =
        capture_request(fn ->
          Users.set_channel_type_preferences(client, "u1", "email", false)
        end)

      assert {req.path, req.body} == {base <> "/channel_types/email", %{"subscribed" => false}}

      {_, req} =
        capture_request(fn -> Users.set_workflows_preferences(client, "u1", %{"wf" => true}) end)

      assert {req.path, req.body} == {base <> "/workflows", %{"wf" => true}}

      {_, req} =
        capture_request(fn -> Users.set_workflow_preferences(client, "u1", "wf", true) end)

      assert {req.path, req.body} == {base <> "/workflows/wf", %{"subscribed" => true}}

      {_, req} =
        capture_request(fn ->
          Users.set_workflow_preferences(client, "u1", "wf", %{channel_types: %{email: true}})
        end)

      assert req.body == %{"channel_types" => %{"email" => true}}

      {_, req} =
        capture_request(fn ->
          Users.set_categories_preferences(client, "u1", %{"cat" => true})
        end)

      assert {req.path, req.body} == {base <> "/categories", %{"cat" => true}}

      {_, req} =
        capture_request(fn ->
          Users.set_category_preferences(client, "u1", "cat", false, preference_set: "other")
        end)

      assert {req.path, req.body} ==
               {"/users/u1/preferences/other/categories/cat", %{"subscribed" => false}}
    end
  end

  describe "messages, schedules and subscriptions" do
    test "get_messages/3", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Users.get_messages(client, "u1", status: ["delivered"], trigger_data: %{"a" => 1})
        end)

      assert {req.method, req.path} == {:get, "/users/u1/messages"}
      assert req.query == q(~s(status[]=delivered&trigger_data={"a":1}))
    end

    test "get_schedules/3", %{client: client} do
      {_, req} = capture_request(fn -> Users.get_schedules(client, "u1", workflow: "wf") end)
      assert {req.method, req.path, req.query} == {:get, "/users/u1/schedules", "workflow=wf"}
    end

    test "get_subscriptions/3", %{client: client} do
      {_, req} = capture_request(fn -> Users.get_subscriptions(client, "u1", page_size: 5) end)

      assert {req.method, req.path, req.query} ==
               {:get, "/users/u1/subscriptions", "page_size=5"}
    end
  end
end
