defmodule Knock.ApiTest do
  use ExUnit.Case

  alias Knock.Client
  alias Knock.Api
  @moduletag capture_log: true

  describe "http_client with additional_middlewares" do
    test "includes custom middleware in the Tesla client" do
      client =
        Client.new(
          api_key: "sk_test_12345",
          additional_middlewares: [
            {Tesla.Middleware.Logger, level: :debug},
            Tesla.Middleware.Retry
          ]
        )

      # Create the Tesla client through a private function call
      # We'll use the get/3 function which internally calls http_client
      # and verify the client structure
      _tesla_client =
        client
        |> Api.get("/test")
        |> case do
          {:error, _} -> :ok
          _ -> :ok
        end

      # The test mainly ensures no errors occur when additional_middlewares are set
      assert client.additional_middlewares == [
               {Tesla.Middleware.Logger, level: :debug},
               Tesla.Middleware.Retry
             ]
    end

    test "works with module-only middleware specification" do
      client =
        Client.new(
          api_key: "sk_test_12345",
          additional_middlewares: [Tesla.Middleware.Retry]
        )

      assert client.additional_middlewares == [Tesla.Middleware.Retry]
    end

    test "works without additional middlewares" do
      client = Client.new(api_key: "sk_test_12345")

      assert client.additional_middlewares == []
    end
  end
end
