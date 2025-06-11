defmodule Knock.Client do
  @moduledoc """
  Sets up a configurable client that can interface with the Knock API. Expects at least
  an API key to be provided.

  ### Example usage
  ```elixir
  # Setup a client instance directly
  client = Knock.Client.new(api_key: "sk_test_12345")
  ```
  """

  @enforce_keys [:api_key]
  defstruct host: "https://api.knock.app",
            api_key: nil,
            adapter: Tesla.Adapter.Hackney,
            json_client: Jason,
            middleware_callback: nil

  @typedoc """
  Describes a Knock client
  """
  @type t :: %__MODULE__{
          host: String.t(),
          api_key: String.t(),
          adapter: atom(),
          json_client: atom(),
          middleware_callback: ([atom()] -> [atom()])
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

    opts = Keyword.take(opts, [:host, :api_key, :adapter, :json_client, :middleware_callback])
    struct!(__MODULE__, opts)
  end
end
