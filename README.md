# Knock

Knock API access for applications written in Elixir.

## Documentation

See the [package documentation](https://hexdocs.pm/knock) as well as [API documentation](https://docs.knock.app) for usage examples.

## Installation

Add the package to your `mix.exs` file as follows:

```elixir
def deps do
  [
    {:knock, "~> 0.5"}
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
knock_client = MyApp.Knock.client(api_key: "sk_12345")
```

To use a branch, set the `branch` option in your configuration or client instance:

```elixir
config :my_app, MyApp.Knock,
  api_key: "sk_12345"
  branch: "my-feature-branch"

# OR

knock_client = MyApp.Knock.client(api_key: "sk_12345", branch: "my-feature-branch")
```

Alternatively, you can set it as an environment variable:

```bash
KNOCK_BRANCH="my-feature-branch"
```

### Retries and timeouts

The client doesn't retry failed requests. You can add retries with Tesla middleware. Retrying
non-idempotent requests (such as workflow triggers) can send duplicate notifications, so either
limit retries to reads or pass an `:idempotency_key` when triggering workflows:

```elixir
knock_client =
  MyApp.Knock.client(
    additional_middlewares: [
      {Tesla.Middleware.Retry,
       max_retries: 2,
       delay: 500,
       should_retry: fn result, env, _context ->
         env.method == :get and match?({:error, _}, result)
       end}
    ]
  )
```

The default Finch adapter waits up to 15 seconds for a response. To change this, configure the
adapter's `:receive_timeout`:

```elixir
knock_client =
  MyApp.Knock.client(adapter: {Tesla.Adapter.Finch, name: Knock.Finch, receive_timeout: 30_000})
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
|> Knock.Workflows.trigger("dinosaurs-loose", %{
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

# Set preference set for user (replaces the existing preference set)
Knock.Users.set_preferences(client, "jhammond", %{channel_types: %{email: true}})

# Update part of the preference set, merging with existing preferences
Knock.Users.set_preferences(client, "jhammond", %{
  "__persistence_strategy__" => "merge",
  "workflows" => %{"dinosaurs-loose" => %{"channel_types" => %{"email" => true}}}
})

# Retrieve preferences
Knock.Users.get_preferences(client, "jhammond")

# Retrieve preferences resolved for a tenant
Knock.Users.get_preferences(client, "jhammond", tenant: "jurassic-park")
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

### Scheduling workflows

```elixir
client = MyApp.Knock.client()

Knock.Schedules.create(client, %{
  workflow: "daily-digest",
  recipients: ["jhammond"],
  repeats: [%{frequency: "daily", hours: 9, minutes: 0}]
})

Knock.Schedules.list(client, "daily-digest", recipients: ["jhammond"])
```

### Signing user tokens

When enhanced security mode is enabled, client-side SDKs need a user token signed with your
environment's signing key (found in the Knock dashboard). Add the optional `jose` dependency:

```elixir
def deps do
  [
    {:knock, "~> 0.5"},
    {:jose, "~> 1.11"}
  ]
end
```

Then sign tokens with `Knock.UserTokens`. The signing key is read from `KNOCK_SIGNING_KEY` unless
passed explicitly:

```elixir
{:ok, token} = Knock.UserTokens.sign("jhammond")

# With a custom expiry and grants, e.g. for Slack channel pickers
{:ok, token} =
  Knock.UserTokens.sign("jhammond",
    signing_key: System.get_env("KNOCK_SIGNING_KEY"),
    expires_in_seconds: 60 * 60 * 24,
    grants: [
      Knock.UserTokens.build_grant(%{type: :object, collection: "projects", id: "p1"}, [
        Knock.UserTokens.slack_channels_read(),
        Knock.UserTokens.channel_data_read()
      ])
    ]
  )
```

You can read more about [clientside authentication here](https://docs.knock.app/client-integration/authenticating-users).
