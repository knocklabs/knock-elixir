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
            json_client: Jason

  @typedoc """
  Describes a Knock client
  """
  @type t :: %__MODULE__{
          host: String.t(),
          api_key: String.t(),
          adapter: atom(),
          json_client: atom()
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
      |> Keyword.take([:host, :api_key, :adapter, :json_client])
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
