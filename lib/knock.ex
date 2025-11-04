defmodule Knock do
  @moduledoc """
  Official SDK for interacting with Knock.

  ## Example usage

  ### As a module

  The recommended way to configure Knock is as a module in your application. Doing so will
  allow you to customize the options via configuration in your app.

  ```elixir
  # lib/my_app/knock.ex

  defmodule MyApp.Knock do
    use Knock, otp_app: :my_app
  end

  # config/runtime.exs

  config :my_app, MyApp.KnockClient,
    api_key: System.get_env("KNOCK_API_KEY")
  ```

  In your application you can now execute commands on your configured Knock instance.

  ```elixir
  client = MyApp.Knock.client()
  {:ok, user} = Knock.Users.get_user(client, "user_1")
  ```

  ### Invoking directly

  Optionally you can forgo implementing your own Knock module and create client instances
  manually:

  ```elixir
  client = Knock.Client.new(api_key: "sk_test_12345")
  ```

  ### Customizing options

  Out of the box the client will specify Tesla and Jason as the HTTP adapter and JSON client,
  respectively. However, you can customize this at will:

  ```elixir
  config :my_app, Knock,
    adapter: Tesla.Adapter.Finch,
    json_client: JSX
  ```

  You can read more about the availble adapters in the [Tesla documentation](https://hexdocs.pm/tesla/readme.html#adapters)
  """

  defmacro __using__(opts) do
    quote do
      @app_name Keyword.fetch!(unquote(opts), :otp_app)
      @api_key_env_var "KNOCK_API_KEY"
      @branch_env_var "KNOCK_BRANCH"

      alias Knock.Client

      @doc """
      Creates a new client, reading the configuration set for this
      applicaton and module in the process
      """
      def client(overrides \\ []) do
        overrides
        |> fetch_options()
        |> Client.new()
      end

      defp fetch_options(overrides) do
        Application.get_env(@app_name, __MODULE__, [])
        |> maybe_resolve_api_key()
        |> maybe_resolve_branch()
        |> Keyword.merge(overrides)
      end

      defp maybe_resolve_api_key(opts) do
        case Keyword.get(opts, :api_key) do
          api_key when is_binary(api_key) -> opts
          {:system, var_name} -> Keyword.put(opts, :api_key, System.get_env(var_name))
          _ -> Keyword.put(opts, :api_key, System.get_env(@api_key_env_var))
        end
      end

      defp maybe_resolve_branch(opts) do
        case Keyword.get(opts, :branch) do
          branch when is_binary(branch) -> opts
          {:system, var_name} -> Keyword.put(opts, :branch, System.get_env(var_name))
          _ -> Keyword.put(opts, :branch, System.get_env(@branch_env_var))
        end
      end
    end
  end

  @doc """
  Issues a notify call, triggering a workflow with the given key.
  """
  defdelegate notify(client, key, properties, options \\ []), to: Knock.Workflows, as: :trigger
end
