defmodule Knock.Client do
  @moduledoc """
  Sets up a configurable client that can interface with the Knock API. Expects at least
  an API key to be provided.

  ### Example usage
  ```elixir
  # Setup a client instance directly
  client = Knock.Client.new(api_key: "sk_test_12345")

  # With optional branch
  client = Knock.Client.new(api_key: "sk_test_12345", branch: "my-feature-branch")

  # With custom Req options
  client = Knock.Client.new(
    api_key: "sk_test_12345",
    req_options: [connect_options: [timeout: 30_000]]
  )
  ```

  ### Custom Req options

  You can pass additional Req options via `:req_options` when creating a client. These options
  are merged into every HTTP request made by the client. This is useful for configuring timeouts,
  retries, or using a custom Finch pool.

  ```elixir
  # Using a custom Finch pool (add {Finch, name: MyApp.Finch} to your supervision tree)
  client = Knock.Client.new(
    api_key: "sk_test_12345",
    req_options: [finch: MyApp.Finch]
  )
  ```
  """

  @enforce_keys [:api_key]
  defstruct host: "https://api.knock.app",
            api_key: nil,
            branch: nil,
            req_options: []

  @typedoc """
  Describes a Knock client
  """
  @type t :: %__MODULE__{
          host: String.t(),
          api_key: String.t(),
          branch: String.t() | nil,
          req_options: keyword()
        }

  @doc """
  Creates a new client struct with the provided options. The options provided must at least
  contain an API secret key, which can be obtained in the Knock dashboard.
  """
  @spec new(Keyword.t()) :: t()
  def new(opts) do
    unless Keyword.get(opts, :api_key) do
      raise Knock.ApiKeyMissingError
    end

    opts =
      opts
      |> Keyword.take([:host, :api_key, :branch, :req_options])
      |> Map.new()

    struct!(__MODULE__, opts)
  end
end
