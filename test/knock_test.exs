defmodule KnockTest do
  use ExUnit.Case
  doctest Knock

  defmodule TestClient do
    use Knock, otp_app: :knock
  end

  describe "using a module to create a client" do
    test "it can have configuration set along with the defaults" do
      knock = TestClient.client(api_key: "sk_test_12345")

      assert knock.api_key == "sk_test_12345"
      assert knock.host == "https://api.knock.app"
      assert knock.branch == nil
      assert knock.req_options == []
    end

    test "it allows configuring a branch" do
      knock = TestClient.client(api_key: "sk_test_12345", branch: "my-feature-branch")

      assert knock.api_key == "sk_test_12345"
      assert knock.branch == "my-feature-branch"
    end

    test "it will default to reading the api key from env vars" do
      System.put_env("KNOCK_API_KEY", "sk_test_12345")

      knock = TestClient.client()

      assert knock.api_key == "sk_test_12345"
    end

    test "it will default to reading the branch from env vars" do
      System.put_env("KNOCK_API_KEY", "sk_test_12345")
      System.put_env("KNOCK_BRANCH", "test-branch")

      knock = TestClient.client()

      assert knock.branch == "test-branch"

      System.delete_env("KNOCK_BRANCH")
    end

    test "it can read the api key from application config" do
      Application.put_env(:knock, KnockTest.TestClient,
        api_key: "sk_test_12345",
        foo: "bar"
      )

      knock = TestClient.client()

      assert knock.api_key == "sk_test_12345"
    end

    test "it can read the branch from application config" do
      Application.put_env(:knock, KnockTest.TestClient,
        api_key: "sk_test_12345",
        branch: "config-branch"
      )

      knock = TestClient.client()

      assert knock.api_key == "sk_test_12345"
      assert knock.branch == "config-branch"

      Application.delete_env(:knock, KnockTest.TestClient)
    end

    test "it can accept req_options" do
      knock =
        TestClient.client(
          api_key: "sk_test_12345",
          req_options: [connect_options: [timeout: 30_000]]
        )

      assert knock.req_options == [connect_options: [timeout: 30_000]]
    end

    test "it defaults to empty list for req_options" do
      knock = TestClient.client(api_key: "sk_test_12345")

      assert knock.req_options == []
    end
  end
end
