defmodule Knock.Api.Query do
  @moduledoc false

  # Tesla's query encoder raises on map values, which the Knock API uses for object references
  # (`objects[0][id]=...`) and ranges (`inserted_at[gt]=...`). Only those values are flattened
  # here; every other pair is left for Tesla to encode so the query seen by middleware is
  # unchanged. Lists whose first element is a map use indexed keys, matching the Node SDK:
  # Plug decodes indexed primitives as a map, so scalar lists must stay in `key[]` form.
  # Dates are sent as ISO-8601, since `to_string/1` on a DateTime uses a space separator.

  @date_structs [DateTime, NaiveDateTime, Date]

  @spec encode(Enumerable.t()) :: list()
  def encode(query) do
    Enum.flat_map(query, fn {key, value} = pair ->
      if needs_encoding?(value), do: encode_pair(to_string(key), value), else: [pair]
    end)
  end

  defp needs_encoding?(%struct{}) when struct in @date_structs, do: true
  defp needs_encoding?(value) when is_map(value) and not is_struct(value), do: true

  defp needs_encoding?(value) when is_list(value) do
    Enum.any?(value, fn
      {key, nested} when is_atom(key) or is_binary(key) -> needs_encoding?(nested)
      item -> needs_encoding?(item)
    end)
  end

  defp needs_encoding?(_value), do: false

  defp encode_pair(key, value) when is_map(value) and not is_struct(value),
    do: encode_nested_pairs(key, value)

  defp encode_pair(key, [{nested_key, _} | _] = value)
       when is_atom(nested_key) or is_binary(nested_key),
       do: encode_nested_pairs(key, value)

  defp encode_pair(key, [first | _] = value) when is_map(first) and not is_struct(first) do
    value
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, index} -> encode_pair("#{key}[#{index}]", item) end)
  end

  defp encode_pair(key, value) when is_list(value),
    do: Enum.flat_map(value, &encode_pair("#{key}[]", &1))

  defp encode_pair(key, %struct{} = value) when struct in @date_structs,
    do: [{key, struct.to_iso8601(value)}]

  defp encode_pair(key, value), do: [{key, value}]

  defp encode_nested_pairs(key, value),
    do: Enum.flat_map(value, fn {k, v} -> encode_pair("#{key}[#{k}]", v) end)
end
