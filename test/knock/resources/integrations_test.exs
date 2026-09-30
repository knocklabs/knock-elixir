defmodule Knock.IntegrationsTest do
  use Knock.Case, async: true

  @rpc %{id: "1", jsonrpc: "2.0", method: "test_connection"}

  test "Census.custom_destination/2", %{client: client} do
    {_, req} =
      capture_request(fn -> Knock.Integrations.Census.custom_destination(client, @rpc) end)

    assert {req.method, req.path} == {:post, "/integrations/census/custom-destination"}
    assert req.body == %{"id" => "1", "jsonrpc" => "2.0", "method" => "test_connection"}
  end

  test "Hightouch.embedded_destination/2", %{client: client} do
    {_, req} =
      capture_request(fn -> Knock.Integrations.Hightouch.embedded_destination(client, @rpc) end)

    assert {req.method, req.path} == {:post, "/integrations/hightouch/embedded-destination"}
    assert req.body == %{"id" => "1", "jsonrpc" => "2.0", "method" => "test_connection"}
  end
end
