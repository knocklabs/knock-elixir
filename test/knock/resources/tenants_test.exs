defmodule Knock.TenantsTest do
  use Knock.Case, async: true

  alias Knock.Tenants

  test "list/2", %{client: client} do
    {_, req} = capture_request(fn -> Tenants.list(client, name: "Acme") end)
    assert {req.method, req.path, req.query} == {:get, "/tenants", "name=Acme"}
  end

  test "get/2", %{client: client} do
    {_, req} = capture_request(fn -> Tenants.get(client, "t1") end)
    assert {req.method, req.path, req.query} == {:get, "/tenants/t1", nil}
  end

  test "set/3", %{client: client} do
    {_, req} = capture_request(fn -> Tenants.set(client, "t1", %{name: "Acme"}) end)
    assert {req.method, req.path, req.body} == {:put, "/tenants/t1", %{"name" => "Acme"}}
  end

  test "delete/2", %{client: client} do
    {_, req} = capture_request(fn -> Tenants.delete(client, "t1") end)
    assert {req.method, req.path} == {:delete, "/tenants/t1"}
  end
end
