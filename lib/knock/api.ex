defmodule Knock.Api do
  @moduledoc """
  Api client for interacting with Knock
  """

  alias Knock.Client

  @lib_version Mix.Project.config()[:version]

  @typedoc """
  Describes a response from calling an API function
  """
  @type response :: {:ok, Knock.Response.t()} | {:error, Knock.Response.t()} | {:error, any()}

  @typedoc """
  Defines available options to pass to an API function
  """
  @type options :: [Tesla.option()] | []

  @doc """
  Executes a get request against the Knock api.
  """
  @spec get(Client.t(), String.t(), options()) :: response()
  def get(client, path, opts \\ []) do
    client
    |> http_client()
    |> Tesla.get(path, opts)
    |> handle_response()
  end

  @doc """
  Executes a put request against the Knock api
  """
  @spec put(Client.t(), String.t(), map(), options()) :: response()
  def put(client, path, body, opts \\ []) do
    client
    |> http_client(opts)
    |> Tesla.put(path, body, opts)
    |> handle_response()
  end

  @doc """
  Executes a post request against the Knock api.
  """
  @spec post(Client.t(), String.t(), map(), options()) :: response()
  def post(client, path, body, opts \\ []) do
    client
    |> http_client(opts)
    |> Tesla.post(path, body, opts)
    |> handle_response()
  end

  @doc """
  Executes a delete request against the Knock api.
  """
  @spec delete(Client.t(), String.t(), options()) :: response()
  def delete(client, path, opts \\ []) do
    client
    |> http_client()
    |> Tesla.delete(path, opts)
    |> handle_response()
  end

  defp handle_response({:ok, %Tesla.Env{status: status} = env})
       when status >= 200 and status < 300 do
    {:ok, %Knock.Response{status: status, headers: env.headers, body: env.body, url: env.url}}
  end

  defp handle_response({:ok, %Tesla.Env{status: status} = env}) do
    {:error, %Knock.Response{status: status, headers: env.headers, body: env.body, url: env.url}}
  end

  defp handle_response(result), do: result

  @doc """
  Returns the current version for the library
  """
  def library_version, do: @lib_version

  defp http_client(config, opts \\ []) do
    middleware = [
      {Tesla.Middleware.BaseUrl, config.host <> "/v1"},
      {Tesla.Middleware.JSON, engine: config.json_client},
      {Tesla.Middleware.Headers,
       [
         {"Authorization", "Bearer " <> config.api_key},
         {"User-Agent", "knocklabs/knock-elixir@#{library_version()}"}
       ] ++ maybe_idempotency_key_header(Map.new(opts))}
    ]

    middleware = (config.middleware_callback || & &1).(middleware)

    Tesla.client(middleware, config.adapter)
  end

  defp maybe_idempotency_key_header(%{idempotency_key: key}) when is_binary(key),
    do: [{"Idempotency-Key", key}]

  defp maybe_idempotency_key_header(_), do: []
end
