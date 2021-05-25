# Knock

Knock API access for applications written in Elixir.

## Documentation

See the [package documentation](https://hexdocs.pm/knock) as well as [API documentation](https://docs.knock.app) for usage examples.

## Installation

Add the package to your `mix.exs` file as follows:

```elixir
def deps do
  [
    {:knock, "~> 0.1.3"}
  ]
end
```

## Configuration

Start by defining an Elixir module for your Knock instance:

```elixir
defmodule MyApp.Knock do
  use Knock, otp_app: :my_app
end
```

To use the library you must provide a secret API key, provided in the Knock dashboard.

You can set it as an environment variable:

```bash
KNOCK_API_KEY="sk_12345"
```

Or you can specify it manually in your configuration:

```elixir
config :my_app, MyApp.Knock,
  api_key: "sk_12345"
```

Or you can pass it through when creating a client instance:

```elixir
knock_client = MyApp.Knock.new(api_key: "sk_12345")
```

## Usage

### Identifying users

```elixir
MyApp.Knock.client()
|> Knock.Users.identify("jhammond", %{
  "name" => "John Hammond",
  "email" => "jhammond@ingen.net",
})
```

### Retrieving users

```elixir
MyApp.Knock.client()
|> Knock.Users.get_user("jhammond")
```

### Sending notifies

```elixir
MyApp.Knock.client()
|> Knock.notify("dinosaurs-loose", %{
  # user id of who performed the action
  "actor" => "dnedry",
  # list of user ids for who should receive the notif
  "recipients" => ["jhammond", "agrant", "imalcolm", "esattler"],
  # data payload to send through
  "data" => %{
    "type" => "trex",
    "priority" => 1,
  },
})
```

### Canceling notifies

```elixir
MyApp.Knock.client()
|> Knock.Notify.cancel("dinosaurs-loose", alert.id, %{
  # optional list of user ids for who should have their notify canceled
  "recipients" => ["jhammond", "agrant", "imalcolm", "esattler"],
})
```

### Signing JWTs

You can use the excellent `joken` package to [sign JWTs easily](https://hexdocs.pm/joken/assymetric_cryptography_signers.html#using-asymmetric-algorithms).
You will need to generate an environment specific signing key, which you can find in the Knock dashboard.

If you're using a signing token you will need to pass this to your client to perform authentication.
You can read more about [clientside authentication here](https://docs.knock.app/client-integration/authenticating-users).

```elixir
priv = System.get_env("KNOCK_SIGNING_KEY")
now = DateTime.utc_now()

claims = %{
  # The user id to sign this key for
  "sub" => user_id,
  # When the token was issued
  "iat" => DateTime.to_unix(now),
  # When the token expires (1 hour)
  "exp" => DateTime.add(now, 3600, :seconds) |> DateTime.to_unix()
}


signer = Joken.Signer.create("RS256", %{"pem" => priv})
{:ok, token, _} = Joken.generate_and_sign(%{}, claims, signer)
```
