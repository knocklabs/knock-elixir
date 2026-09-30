defmodule Knock.ResourceHelpers do
  @moduledoc false

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
  passing strings through unchanged. `param_key` is only used in the error message.
  """
  @spec json_encode_value(map() | String.t(), atom(), module()) :: String.t()
  def json_encode_value(value, _param_key, _json_client) when is_binary(value), do: value

  def json_encode_value(value, _param_key, json_client) when is_map(value),
    do: json_client.encode!(value)

  def json_encode_value(_value, param_key, _json_client) do
    raise ArgumentError, "Incorrect #{param_key} type, expected a map or a JSON-encoded string"
  end

  @doc """
  Builds a single-pair query list holding the JSON-encoded value under `param_key`.
  """
  @spec json_query_param(Knock.Client.t(), atom(), map() | String.t()) :: Keyword.t()
  def json_query_param(client, param_key, value),
    do: [{param_key, json_encode_value(value, param_key, client.json_client)}]

  @doc """
  Builds the body for a single workflow, category or channel type preference setting.
  """
  @spec build_setting_param(map() | boolean()) :: map()
  def build_setting_param(setting) when is_map(setting), do: setting
  def build_setting_param(setting), do: %{subscribed: setting}
end
