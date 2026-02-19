defmodule Knock.Response do
  @moduledoc """
  Represents a response back from Knock
  """

  @enforce_keys [:body, :headers, :status]

  defstruct [
    :url,
    :body,
    :headers,
    :status
  ]

  @type t :: %__MODULE__{
          url: String.t() | nil,
          body: map(),
          headers: %{optional(String.t()) => [String.t()]},
          status: pos_integer()
        }
end
