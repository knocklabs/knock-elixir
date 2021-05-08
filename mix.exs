defmodule Knock.MixProject do
  use Mix.Project

  def project do
    [
      app: :knock,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4.1"},
      {:hackney, "~> 1.17.0"},
      {:jason, "~> 1.1"}
    ]
  end
end
