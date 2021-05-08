defmodule Knock.Response do
  @moduledoc """
  Represents a response back from Knock
  """

  @enforce_keys [:body, :headers, :status, :url]

  defstruct [
    :url,
    :body,
    :headers,
    :status
  ]

  @type t :: %__MODULE__{
          url: String.t(),
          body: map(),
          headers: [],
          status: pos_integer()
        }
end
