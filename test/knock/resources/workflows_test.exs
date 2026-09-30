defmodule Knock.WorkflowsTest do
  use Knock.Case, async: true

  alias Knock.Workflows

  describe "trigger/4" do
    test "posts to the workflow trigger endpoint", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Workflows.trigger(client, "wf", %{recipients: ["u1"], data: %{a: 1}})
        end)

      assert {req.method, req.path} == {:post, "/workflows/wf/trigger"}
      assert req.body == %{"recipients" => ["u1"], "data" => %{"a" => 1}}
    end

    test "sends an idempotency key header", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Workflows.trigger(client, "wf", %{recipients: ["u1"]}, idempotency_key: 123)
        end)

      assert {"Idempotency-Key", "123"} in req.headers
    end

    test "Knock.notify/4 delegates to trigger", %{client: client} do
      {_, req} = capture_request(fn -> Knock.notify(client, "wf", %{recipients: ["u1"]}) end)
      assert {req.method, req.path} == {:post, "/workflows/wf/trigger"}
    end
  end

  test "cancel/4", %{client: client} do
    {_, req} =
      capture_request(fn ->
        Workflows.cancel(client, "wf", "key_1", %{"recipients" => ["u1"]})
      end)

    assert {req.method, req.path} == {:post, "/workflows/wf/cancel"}
    assert req.body == %{"cancellation_key" => "key_1", "recipients" => ["u1"]}
  end

  describe "schedules" do
    test "create_schedules/3", %{client: client} do
      {_, req} =
        capture_request(fn -> Workflows.create_schedules(client, "wf", %{recipients: ["u1"]}) end)

      assert {req.method, req.path} == {:post, "/schedules"}
      assert req.body == %{"workflow" => "wf", "recipients" => ["u1"]}
    end

    test "update_schedules/3", %{client: client} do
      {_, req} =
        capture_request(fn -> Workflows.update_schedules(client, ["s1"], %{data: %{a: 1}}) end)

      assert {req.method, req.path} == {:put, "/schedules"}
      assert req.body == %{"schedule_ids" => ["s1"], "data" => %{"a" => 1}}
    end

    test "list_schedules/3", %{client: client} do
      {_, req} = capture_request(fn -> Workflows.list_schedules(client, "wf", tenant: "t1") end)
      assert {req.method, req.path, req.query} == {:get, "/schedules", q("workflow=wf&tenant=t1")}
    end

    test "delete_schedules/2", %{client: client} do
      {_, req} = capture_request(fn -> Workflows.delete_schedules(client, ["s1"]) end)

      assert {req.method, req.path, req.body} ==
               {:delete, "/schedules", %{"schedule_ids" => ["s1"]}}
    end

    test "bulk_create_schedules/2", %{client: client} do
      {_, req} =
        capture_request(fn ->
          Workflows.bulk_create_schedules(client, [%{workflow: "wf", recipient: "u1"}])
        end)

      assert {req.method, req.path} == {:post, "/schedules/bulk/create"}
      assert req.body == %{"schedules" => [%{"workflow" => "wf", "recipient" => "u1"}]}
    end
  end
end
