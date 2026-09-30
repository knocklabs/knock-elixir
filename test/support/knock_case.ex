defmodule Knock.Case do
  @moduledoc """
  Test case for resource modules. Provides a client backed by `Tesla.Mock` and helpers for
  capturing the request that a resource function issues.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      import Knock.Case
    end
  end

  setup do
    {:ok, client: Knock.Client.new(api_key: "sk_test_12345", adapter: Tesla.Mock)}
  end

  @base_url "https://api.knock.app/v1"

  @doc """
  Executes `fun` against a mocked adapter and returns `{result, request}`, where `request`
  is a map with the `:method`, `:path` (relative to `/v1`), decoded `:query` string,
  decoded JSON `:body` and `:headers` of the issued request.
  """
  def capture_request(fun, response \\ []) do
    test_pid = self()
    status = Keyword.get(response, :status, 200)
    body = Keyword.get(response, :body, %{})

    Tesla.Mock.mock(fn env ->
      send(test_pid, {:knock_request, env})
      %Tesla.Env{env | status: status, body: body}
    end)

    result = fun.()

    receive do
      {:knock_request, env} -> {result, normalize(env)}
    after
      0 -> ExUnit.Assertions.flunk("expected a request to be issued")
    end
  end

  defp normalize(env) do
    %{
      method: env.method,
      path: String.replace_prefix(env.url, @base_url, ""),
      query: decode_query(env.query),
      body: decode_body(env.body),
      headers: env.headers
    }
  end

  @doc """
  Normalizes a query string so assertions don't depend on parameter order.
  """
  def q(query) do
    query
    |> String.split("&")
    |> Enum.sort()
    |> Enum.join("&")
  end

  defp decode_query([]), do: nil

  defp decode_query(query) do
    query
    |> Tesla.encode_query()
    |> URI.decode_www_form()
    |> q()
  end

  defp decode_body(nil), do: nil
  defp decode_body(body) when is_binary(body), do: Jason.decode!(body)
  defp decode_body(body), do: body |> IO.iodata_to_binary() |> Jason.decode!()
end
