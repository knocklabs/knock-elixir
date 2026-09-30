defmodule Knock.UserTokens do
  @moduledoc """
  Signs user tokens (JWTs) for authenticating users with Knock's client-side SDKs when
  enhanced security mode is enabled.

  Requires the optional `:jose` dependency:

  ```elixir
  {:jose, "~> 1.11"}
  ```

  ### Example usage

  ```elixir
  {:ok, token} = Knock.UserTokens.sign("user_1")

  # With a custom expiry and grants
  {:ok, token} =
    Knock.UserTokens.sign("user_1",
      expires_in_seconds: 60 * 60 * 24,
      grants: [
        Knock.UserTokens.build_grant(%{type: :object, collection: "projects", id: "p1"}, [
          Knock.UserTokens.slack_channels_read()
        ])
      ]
    )
  ```
  """

  @compile {:no_warn_undefined, [JOSE.JWK, JOSE.JWS, JOSE.JWT]}

  @signing_key_env_var "KNOCK_SIGNING_KEY"
  @default_hostname "https://api.knock.app"
  @default_expires_in_seconds 60 * 60
  @base64_pem_prefix "LS0tLS1CRUdJTi"

  @typedoc """
  The resource a grant applies to
  """
  @type entity ::
          %{type: :user, id: String.t()}
          | %{type: :tenant, id: String.t()}
          | %{type: :object, id: String.t(), collection: String.t()}

  @typedoc """
  A set of grants for a single entity, as built by `build_grant/2`
  """
  @type grant :: %{entity: String.t(), grants: %{String.t() => []}}

  @typedoc """
  Options accepted by `sign/2`
  """
  @type sign_option ::
          {:signing_key, String.t()}
          | {:expires_in_seconds, pos_integer()}
          | {:grants, [grant()]}
          | {:generate_jti, boolean()}

  @doc "Grant to read the Slack channels available to an entity"
  @spec slack_channels_read() :: String.t()
  def slack_channels_read, do: "slack/channels_read"

  @doc "Grant to read the Microsoft Teams channels available to an entity"
  @spec ms_teams_channels_read() :: String.t()
  def ms_teams_channels_read, do: "ms_teams/channels_read"

  @doc "Grant to read an entity's channel data"
  @spec channel_data_read() :: String.t()
  def channel_data_read, do: "channel_data/read"

  @doc "Grant to write an entity's channel data"
  @spec channel_data_write() :: String.t()
  def channel_data_write, do: "channel_data/write"

  @doc "Grant to read a user's feed"
  @spec user_feed_read() :: String.t()
  def user_feed_read, do: "user/feed_read"

  @doc """
  Builds a grant of the given permissions on an entity (a user, tenant or object), to be
  passed in the `:grants` option of `sign/2`.
  """
  @spec build_grant(entity(), [String.t()]) :: grant()
  def build_grant(entity, grants) do
    %{entity: entity_uri(entity), grants: Map.new(grants, &{&1, []})}
  end

  @doc """
  Signs a user token for the given user id.

  ## Available options:

  * `:signing_key` - the RSA private key to sign with, as a PEM or base64-encoded PEM string.
    Defaults to the `KNOCK_SIGNING_KEY` environment variable
  * `:expires_in_seconds` - how long the token is valid for (defaults to 1 hour)
  * `:grants` - list of grants built with `build_grant/2`
  * `:generate_jti` - when true, adds a unique `jti` claim to the token
  """
  @spec sign(String.t(), [sign_option()]) ::
          {:ok, String.t()} | {:error, :missing_signing_key | :invalid_signing_key}
  def sign(user_id, options \\ []) do
    ensure_jose_loaded!()

    with {:ok, pem} <- signing_key(options),
         {:ok, jwk} <- parse_signing_key(pem) do
      now = System.system_time(:second)

      claims =
        %{
          "sub" => user_id,
          "iat" => now,
          "exp" => now + Keyword.get(options, :expires_in_seconds, @default_expires_in_seconds)
        }
        |> maybe_put_grants(Keyword.get(options, :grants))
        |> maybe_put_jti(Keyword.get(options, :generate_jti, false))

      {_, token} =
        jwk
        |> JOSE.JWT.sign(%{"alg" => "RS256", "typ" => "JWT"}, claims)
        |> JOSE.JWS.compact()

      {:ok, token}
    end
  end

  defp entity_uri(%{type: :user, id: id}), do: "#{@default_hostname}/v1/users/#{id}"
  defp entity_uri(%{type: :tenant, id: id}), do: "#{@default_hostname}/v1/objects/$tenants/#{id}"

  defp entity_uri(%{type: :object, id: id, collection: collection}),
    do: "#{@default_hostname}/v1/objects/#{collection}/#{id}"

  defp signing_key(options) do
    case Keyword.get(options, :signing_key) || System.get_env(@signing_key_env_var) do
      nil -> {:error, :missing_signing_key}
      "" -> {:error, :missing_signing_key}
      key -> prepare_signing_key(key)
    end
  end

  defp prepare_signing_key("-----BEGIN" <> _ = pem), do: {:ok, pem}

  defp prepare_signing_key(@base64_pem_prefix <> _ = encoded) do
    case Base.decode64(encoded) do
      {:ok, pem} -> {:ok, pem}
      :error -> {:error, :invalid_signing_key}
    end
  end

  defp prepare_signing_key(_key), do: {:error, :invalid_signing_key}

  defp parse_signing_key(pem) do
    case JOSE.JWK.from_pem(pem) do
      jwk when is_struct(jwk) -> {:ok, jwk}
      _ -> {:error, :invalid_signing_key}
    end
  rescue
    _ -> {:error, :invalid_signing_key}
  end

  defp maybe_put_grants(claims, nil), do: claims

  defp maybe_put_grants(claims, grants) do
    merged =
      Enum.reduce(grants, %{}, fn %{entity: entity, grants: entity_grants}, acc ->
        Map.update(acc, entity, entity_grants, &Map.merge(&1, entity_grants))
      end)

    Map.put(claims, "grants", merged)
  end

  defp maybe_put_jti(claims, true), do: Map.put(claims, "jti", uuid4())
  defp maybe_put_jti(claims, _), do: claims

  defp uuid4 do
    <<a::48, _::4, b::12, _::2, c::62>> = :crypto.strong_rand_bytes(16)

    <<p1::binary-8, p2::binary-4, p3::binary-4, p4::binary-4, p5::binary-12>> =
      Base.encode16(<<a::48, 4::4, b::12, 2::2, c::62>>, case: :lower)

    Enum.join([p1, p2, p3, p4, p5], "-")
  end

  defp ensure_jose_loaded! do
    unless Code.ensure_loaded?(JOSE.JWT) do
      raise RuntimeError,
            "Knock.UserTokens requires the :jose dependency. Add {:jose, \"~> 1.11\"} to your deps."
    end
  end
end
