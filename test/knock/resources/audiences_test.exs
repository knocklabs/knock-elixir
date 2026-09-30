defmodule Knock.AudiencesTest do
  use Knock.Case, async: true

  alias Knock.Audiences

  test "add_members/4", %{client: client} do
    {_, req} =
      capture_request(fn ->
        Audiences.add_members(client, "vip", [%{user: %{id: "u1"}, tenant: "t1"}],
          create_audience: true
        )
      end)

    assert {req.method, req.path, req.query} ==
             {:post, "/audiences/vip/members", "create_audience=true"}

    assert req.body == %{"members" => [%{"user" => %{"id" => "u1"}, "tenant" => "t1"}]}
  end

  test "list_members/2", %{client: client} do
    {_, req} = capture_request(fn -> Audiences.list_members(client, "vip") end)
    assert {req.method, req.path} == {:get, "/audiences/vip/members"}
  end

  test "remove_members/3 sends a JSON body", %{client: client} do
    {_, req} =
      capture_request(fn -> Audiences.remove_members(client, "vip", [%{user: %{id: "u1"}}]) end)

    assert {req.method, req.path, req.body} ==
             {:delete, "/audiences/vip/members", %{"members" => [%{"user" => %{"id" => "u1"}}]}}
  end
end
