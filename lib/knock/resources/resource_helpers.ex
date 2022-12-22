defmodule Knock.ResourceHelpers do
  @doc """
  Helpers for building resources API requests
  """

  @spec maybe_json_encode_param(Keyword.t(), String.t()) :: Keyword.t()
  def maybe_json_encode_param(options, param_key) do
    case options[param_key] do
      param when is_map(param) ->
        encoded_param = Jason.encode!(param)
        Keyword.put(options, param_key, encoded_param)

      param when is_nil(param) ->
        options

      _ ->
        raise "Incorrect #{param_key} type, expected map"
    end
  end
end
