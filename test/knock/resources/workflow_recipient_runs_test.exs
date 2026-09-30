defmodule Knock.WorkflowRecipientRunsTest do
  use Knock.Case, async: true

  alias Knock.WorkflowRecipientRuns

  test "list/2", %{client: client} do
    {_, req} =
      capture_request(fn ->
        WorkflowRecipientRuns.list(client,
          workflow: "wf",
          status: ["completed", "cancelled"],
          recipient: %{id: "p1", collection: "projects"},
          has_errors: true
        )
      end)

    assert {req.method, req.path} == {:get, "/workflow_recipient_runs"}

    assert req.query ==
             q(
               "workflow=wf&status[]=completed&status[]=cancelled&" <>
                 "recipient[collection]=projects&recipient[id]=p1&has_errors=true"
             )
  end

  test "get/2", %{client: client} do
    {_, req} = capture_request(fn -> WorkflowRecipientRuns.get(client, "run_1") end)
    assert {req.method, req.path} == {:get, "/workflow_recipient_runs/run_1"}
  end
end
