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

  test "get/3 and set/4 send resolve_full_preference_settings as query", %{client: client} do
    {_, req} =
      capture_request(fn -> Tenants.get(client, "t1", resolve_full_preference_settings: true) end)

    assert {req.method, req.path, req.query} ==
             {:get, "/tenants/t1", "resolve_full_preference_settings=true"}

    {_, req} =
      capture_request(fn ->
        Tenants.set(client, "t1", %{name: "Acme"}, resolve_full_preference_settings: true)
      end)

    assert {req.method, req.path, req.query, req.body} ==
             {:put, "/tenants/t1", "resolve_full_preference_settings=true", %{"name" => "Acme"}}
  end

  test "bulk_set/2", %{client: client} do
    {_, req} = capture_request(fn -> Tenants.bulk_set(client, [%{id: "t1", name: "Acme"}]) end)

    assert {req.method, req.path, req.body} ==
             {:post, "/tenants/bulk/set", %{"tenants" => [%{"id" => "t1", "name" => "Acme"}]}}
  end

  test "bulk_delete/2 sends tenant ids as query params", %{client: client} do
    {_, req} = capture_request(fn -> Tenants.bulk_delete(client, ["t1", "t2"]) end)

    assert {req.method, req.path} == {:post, "/tenants/bulk/delete"}
    assert req.query == q("tenant_ids[]=t1&tenant_ids[]=t2")
    assert req.body == %{}
  end
end
