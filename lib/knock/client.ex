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

  # With custom Tesla middleware
  client = Knock.Client.new(
    api_key: "sk_test_12345",
    additional_middlewares: [
      {Tesla.Middleware.Logger, level: :debug, filter_headers: ["Authorization"]},
      Tesla.Middleware.Retry
    ]
  )
  ```

  ### Custom middleware

  You can add custom Tesla middleware to the HTTP client by passing the `:additional_middlewares`
  option when creating a client. This is useful for adding logging, retry logic, or other
  custom behavior to HTTP requests without modifying the library itself.

  Middleware can be specified as either:
  - A module atom: `Tesla.Middleware.Retry`
  - A tuple with module and options: `{Tesla.Middleware.Logger, level: :debug, filter_headers: ["Authorization"]}`

  The additional middlewares are appended to the end of the middleware chain, after the
  built-in middlewares (BaseUrl, JSON, and Headers).
  """

  @enforce_keys [:api_key]
  defstruct host: "https://api.knock.app",
            api_key: nil,
            branch: nil,
            adapter: Tesla.Adapter.Hackney,
            json_client: Jason,
            additional_middlewares: []

  @typedoc """
  Describes a Knock client
  """
  @type t :: %__MODULE__{
          host: String.t(),
          api_key: String.t(),
          branch: String.t() | nil,
          adapter: atom(),
          json_client: atom(),
          additional_middlewares: [module() | {module(), any()}]
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
      |> Keyword.take([:host, :api_key, :branch, :adapter, :json_client, :additional_middlewares])
      |> Map.new()
      |> maybe_set_adapter_default()

    struct!(__MODULE__, opts)
  end

  defp maybe_set_adapter_default(%{adapter: adapter} = opts) when not is_nil(adapter),
    do: opts

  defp maybe_set_adapter_default(opts) do
    # Use the default adapter if one is not provided (if set using Tesla)
    case Application.get_env(:tesla, :adapter) do
      default when not is_nil(default) -> Map.put(opts, :adapter, default)
      _ -> opts
    end
  end
end
