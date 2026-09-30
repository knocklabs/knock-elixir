defmodule Knock.Integrations.Hightouch do
  @moduledoc """
  Knock resources for the Hightouch embedded destination integration
  """
  alias Knock.Api
  alias Knock.Client

  @doc """
  Processes a Hightouch embedded destination RPC request.

  Expected properties:
  - id: the unique identifier for the RPC request
  - jsonrpc: the JSON-RPC version
  - method: the method name to execute
  - params (optional): the parameters for the method
  """
  @spec embedded_destination(Client.t(), map()) :: Api.response()
  def embedded_destination(client, rpc_request) do
    Api.post(client, "/integrations/hightouch/embedded-destination", rpc_request)
  end
end
