defmodule Knock.ApiTest do
  use ExUnit.Case

  alias Knock.Client
  @moduletag capture_log: true

  describe "client with req_options" do
    test "stores custom req_options in the client struct" do
      client =
        Client.new(
          api_key: "sk_test_12345",
          req_options: [connect_options: [timeout: 30_000]]
        )

      assert client.req_options == [connect_options: [timeout: 30_000]]
    end

    test "stores finch option in req_options" do
      client =
        Client.new(
          api_key: "sk_test_12345",
          req_options: [finch: MyApp.Finch]
        )

      assert client.req_options == [finch: MyApp.Finch]
    end

    test "works without req_options" do
      client = Client.new(api_key: "sk_test_12345")

      assert client.req_options == []
    end
  end
end
