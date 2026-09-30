defmodule Knock.Integrations.Census do
  @moduledoc """
  Knock resources for the Census custom destination integration
  """
  alias Knock.Api
  alias Knock.Client

  @doc """
  Processes a Census custom destination RPC request.

  Expected properties:
  - id: the unique identifier for the RPC request
  - jsonrpc: the JSON-RPC version
  - method: the method name to execute
  - params (optional): the parameters for the method
  """
  @spec custom_destination(Client.t(), map()) :: Api.response()
  def custom_destination(client, rpc_request) do
    Api.post(client, "/integrations/census/custom-destination", rpc_request)
  end
end
