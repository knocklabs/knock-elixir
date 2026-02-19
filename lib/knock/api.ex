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
  @type options :: [{:idempotency_key, String.Chars.t()} | {atom(), any()}]

  @doc """
  Executes a get request against the Knock api.
  """
  @spec get(Client.t(), String.t(), options()) :: response()
  def get(client, path, opts \\ []) do
    client
    |> build_req()
    |> Req.get(url: path, params: Keyword.get(opts, :query))
    |> handle_response()
  end

  @doc """
  Executes a put request against the Knock api
  """
  @spec put(Client.t(), String.t(), map(), options()) :: response()
  def put(client, path, body, opts \\ []) do
    {client_opts, _req_opts} = Keyword.split(opts, [:idempotency_key])

    client
    |> build_req(client_opts)
    |> Req.put(url: path, json: body)
    |> handle_response()
  end

  @doc """
  Executes a post request against the Knock api.
  """
  @spec post(Client.t(), String.t(), map(), options()) :: response()
  def post(client, path, body, opts \\ []) do
    {client_opts, _req_opts} = Keyword.split(opts, [:idempotency_key])

    client
    |> build_req(client_opts)
    |> Req.post(url: path, json: body)
    |> handle_response()
  end

  @doc """
  Executes a delete request against the Knock api.
  """
  @spec delete(Client.t(), String.t(), options()) :: response()
  def delete(client, path, opts \\ []) do
    {client_opts, _req_opts} = Keyword.split(opts, [:idempotency_key])

    client
    |> build_req(client_opts)
    |> Req.delete(url: path)
    |> handle_response()
  end

  defp handle_response({:ok, %Req.Response{status: status} = resp})
       when status >= 200 and status < 300 do
    {:ok, %Knock.Response{status: status, headers: resp.headers, body: resp.body}}
  end

  defp handle_response({:ok, %Req.Response{status: status} = resp}) do
    {:error, %Knock.Response{status: status, headers: resp.headers, body: resp.body}}
  end

  defp handle_response({:error, _} = error), do: error

  @doc """
  Returns the current version for the library
  """
  def library_version, do: @lib_version

  defp build_req(config, opts \\ []) do
    headers = %{
      "authorization" => "Bearer #{config.api_key}",
      "user-agent" => "knocklabs/knock-elixir@#{library_version()}"
    }

    headers = Map.merge(headers, idempotency_key_header(Map.new(opts)))
    headers = Map.merge(headers, branch_header(config))

    base_opts = [
      base_url: config.host <> "/v1",
      headers: headers
    ]

    Req.new(base_opts ++ config.req_options)
  end

  defp idempotency_key_header(%{idempotency_key: key}) when not is_nil(key),
    do: %{"idempotency-key" => to_string(key)}

  defp idempotency_key_header(_), do: %{}

  defp branch_header(%{branch: branch}) when not is_nil(branch),
    do: %{"x-knock-branch" => to_string(branch)}

  defp branch_header(_), do: %{}
end
