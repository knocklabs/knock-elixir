defmodule Knock.UserTokensTest do
  use ExUnit.Case, async: true

  alias Knock.UserTokens

  setup_all do
    jwk = JOSE.JWK.generate_key({:rsa, 2048})
    {_, pem} = JOSE.JWK.to_pem(jwk)
    {:ok, jwk: jwk, pem: pem}
  end

  defp verify!(jwk, token) do
    assert {true, %JOSE.JWT{fields: claims}, %JOSE.JWS{fields: header}} =
             JOSE.JWT.verify_strict(jwk, ["RS256"], token)

    {claims, header}
  end

  test "signs a token for the user with a one hour expiry", %{jwk: jwk, pem: pem} do
    assert {:ok, token} = UserTokens.sign("user_1", signing_key: pem)

    {claims, header} = verify!(jwk, token)
    assert header["typ"] == "JWT"
    assert claims["sub"] == "user_1"
    assert claims["exp"] - claims["iat"] == 3600
    refute Map.has_key?(claims, "grants")
    refute Map.has_key?(claims, "jti")
  end

  test "accepts a base64-encoded PEM and a custom expiry", %{jwk: jwk, pem: pem} do
    assert {:ok, token} =
             UserTokens.sign("user_1", signing_key: Base.encode64(pem), expires_in_seconds: 60)

    {claims, _} = verify!(jwk, token)
    assert claims["exp"] - claims["iat"] == 60
  end

  test "adds a jti when requested", %{jwk: jwk, pem: pem} do
    {:ok, token} = UserTokens.sign("user_1", signing_key: pem, generate_jti: true)

    {claims, _} = verify!(jwk, token)

    assert claims["jti"] =~
             ~r/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/
  end

  test "merges grants per entity", %{jwk: jwk, pem: pem} do
    project = %{type: :object, collection: "projects", id: "p1"}

    grants = [
      UserTokens.build_grant(project, [UserTokens.slack_channels_read()]),
      UserTokens.build_grant(project, [UserTokens.channel_data_read()]),
      UserTokens.build_grant(%{type: :tenant, id: "t1"}, [UserTokens.ms_teams_channels_read()]),
      UserTokens.build_grant(%{type: :user, id: "user_1"}, [UserTokens.user_feed_read()])
    ]

    {:ok, token} = UserTokens.sign("user_1", signing_key: pem, grants: grants)

    {claims, _} = verify!(jwk, token)

    assert claims["grants"] == %{
             "https://api.knock.app/v1/objects/projects/p1" => %{
               "slack/channels_read" => [],
               "channel_data/read" => []
             },
             "https://api.knock.app/v1/objects/$tenants/t1" => %{"ms_teams/channels_read" => []},
             "https://api.knock.app/v1/users/user_1" => %{"user/feed_read" => []}
           }
  end

  test "build_grant/2" do
    assert UserTokens.build_grant(%{type: :user, id: "u1"}, [UserTokens.channel_data_write()]) ==
             %{entity: "https://api.knock.app/v1/users/u1", grants: %{"channel_data/write" => []}}
  end

  test "returns an error for a missing or invalid signing key" do
    System.delete_env("KNOCK_SIGNING_KEY")
    assert UserTokens.sign("user_1") == {:error, :missing_signing_key}
    assert UserTokens.sign("user_1", signing_key: "nope") == {:error, :invalid_signing_key}

    assert UserTokens.sign("user_1", signing_key: "-----BEGIN PRIVATE KEY-----\nnope") ==
             {:error, :invalid_signing_key}
  end
end
