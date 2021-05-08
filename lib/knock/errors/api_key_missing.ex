defmodule Knock.ApiKeyMissingError do
  @moduledoc """
  Exception for when a request is made without an API key.
  """

  defexception message: """
                 The api_key setting is required to make requests to Knock.
                 Please configure :api_key in config.exs, set the KNOCK_API_KEY
                 environment variable, or pass into a new client instance.
               """
end
