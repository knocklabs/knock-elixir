defmodule Knock.SchedulesTest do
  use Knock.Case, async: true

  alias Knock.Schedules

  test "create/2", %{client: client} do
    {_, req} =
      capture_request(fn ->
        Schedules.create(client, %{
          workflow: "wf",
          recipients: ["u1"],
          repeats: [%{frequency: "daily"}]
        })
      end)

    assert {req.method, req.path} == {:post, "/schedules"}

    assert req.body == %{
             "workflow" => "wf",
             "recipients" => ["u1"],
             "repeats" => [%{"frequency" => "daily"}]
           }
  end

  test "update/3", %{client: client} do
    {_, req} = capture_request(fn -> Schedules.update(client, ["s1"], %{data: %{a: 1}}) end)

    assert {req.method, req.path, req.body} ==
             {:put, "/schedules", %{"schedule_ids" => ["s1"], "data" => %{"a" => 1}}}
  end

  test "list/3", %{client: client} do
    {_, req} =
      capture_request(fn ->
        Schedules.list(client, "wf", recipients: ["u1", %{id: "p1", collection: "projects"}])
      end)

    assert {req.method, req.path} == {:get, "/schedules"}

    assert req.query ==
             q(
               "workflow=wf&recipients[]=u1&recipients[][collection]=projects&recipients[][id]=p1"
             )
  end

  test "delete/2", %{client: client} do
    {_, req} = capture_request(fn -> Schedules.delete(client, ["s1"]) end)

    assert {req.method, req.path, req.body} ==
             {:delete, "/schedules", %{"schedule_ids" => ["s1"]}}
  end

  test "bulk_create/2", %{client: client} do
    {_, req} = capture_request(fn -> Schedules.bulk_create(client, [%{workflow: "wf"}]) end)

    assert {req.method, req.path, req.body} ==
             {:post, "/schedules/bulk/create", %{"schedules" => [%{"workflow" => "wf"}]}}
  end
end
