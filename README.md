# Knock

Knock API access for applications written in Elixir.

## Documentation

See the [package documentation](https://hexdocs.pm/knock) as well as [API documentation](https://docs.knock.app) for usage examples.

## Installation

Add the package to your `mix.exs` file as follows:

```elixir
def deps do
  [
    {:knock, "~> 0.3.0"}
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
  # an optional cancellation key
  "cancellation_key" => alert.id,
  # an optional tenant
  "tenant" => "jurassic-park",
  # data payload to send through
  "data" => %{
    "type" => "trex",
    "priority" => 1,
  },
})
```

### User preferences

```elixir
client = MyApp.Knock.client()

# Set preference set for user
Knock.Preferences.set(client, "jhammond", %{channel_types: %{email: true}})

# Set granular channel type preferences
Knock.Preferences.set_channel_type(client, "jhammond", :email, true)

# Set granular workflow preferences
Knock.Preferences.set_workflow(client, "jhammond", "dinosaurs-loose", %{
  channel_types: %{email: true}
})

# Retrieve preferences
Knock.Preferences.get(client, "jhammond")
```

### Getting and setting channel data

```elixir
client = MyApp.Knock.client()

# Set channel data for an APNS
Knock.Users.set_channel_data(client, "jhammond", KNOCK_APNS_CHANNEL_ID, %{
  tokens: [apns_token],
})

# Get channel data for the APNS channel
Knock.Users.get_channel_data(client, "jhammond", KNOCK_APNS_CHANNEL_ID)
```

### Canceling notifies

```elixir
MyApp.Knock.client()
|> Knock.Workflows.cancel("dinosaurs-loose", alert.id, %{
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
