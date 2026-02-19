defmodule Knock.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children =
      if Application.get_env(:knock, :start_finch, true) do
        finch_options = Application.get_env(:knock, :finch_options, [])
        [{Finch, Keyword.put_new(finch_options, :name, Knock.Finch)}]
      else
        []
      end

    Supervisor.start_link(children, strategy: :one_for_one, name: Knock.Supervisor)
  end
end
