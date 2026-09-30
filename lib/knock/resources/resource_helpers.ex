defmodule Knock.ResourceHelpers do
  @moduledoc """
  Helpers for building resources API requests
  """

  @doc """
  JSON encodes the value under `param_key` when it's a map. Values that are already
  JSON-encoded strings are passed through unchanged.
  """
  @spec maybe_json_encode_param(Keyword.t(), atom(), module()) :: Keyword.t()
  def maybe_json_encode_param(options, param_key, json_client \\ Jason) do
    case options[param_key] do
      nil -> options
      param -> Keyword.put(options, param_key, json_encode_value(param, param_key, json_client))
    end
  end

  @doc """
  Returns the value as a JSON-encoded string, encoding maps with the given JSON client and
  passing strings through unchanged.
  """
  @spec json_encode_value(map() | String.t(), atom(), module()) :: String.t()
  def json_encode_value(value, _param_key, _json_client) when is_binary(value), do: value

  def json_encode_value(value, _param_key, json_client) when is_map(value),
    do: json_client.encode!(value)

  def json_encode_value(_value, param_key, _json_client) do
    raise ArgumentError, "Incorrect #{param_key} type, expected a map or a JSON-encoded string"
  end

  @doc """
  Flattens query params into the form the Knock API expects:

  * nested maps and keyword lists use bracket keys (`inserted_at[gt]=...`)
  * lists of scalars use empty brackets (`include[]=preferences`)
  * lists whose first element is a map use indexed keys (`objects[0][id]=...`)
  """
  @spec encode_query(Enumerable.t()) :: [{String.t(), term()}]
  def encode_query(query) do
    Enum.flat_map(query, fn {key, value} -> encode_query_pair(to_string(key), value) end)
  end

  defp encode_query_pair(key, value) when is_map(value) and not is_struct(value),
    do: encode_nested_query_pairs(key, value)

  defp encode_query_pair(key, [{nested_key, _} | _] = value) when is_atom(nested_key),
    do: encode_nested_query_pairs(key, value)

  defp encode_query_pair(key, [first | _] = value) when is_map(first) and not is_struct(first) do
    value
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, index} -> encode_query_pair("#{key}[#{index}]", item) end)
  end

  defp encode_query_pair(key, value) when is_list(value),
    do: Enum.flat_map(value, &encode_query_pair("#{key}[]", &1))

  defp encode_query_pair(key, value), do: [{key, value}]

  defp encode_nested_query_pairs(key, value),
    do: Enum.flat_map(value, fn {k, v} -> encode_query_pair("#{key}[#{k}]", v) end)
end
