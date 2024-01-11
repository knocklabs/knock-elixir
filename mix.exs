defmodule Knock.MixProject do
  use Mix.Project

  @source_url "https://github.com/knocklabs/knock-elixir"
  @version "0.4.13"

  def project do
    [
      app: :knock,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      name: "Knock",
      deps: deps(),
      docs: docs(),
      source_url: @source_url
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
      {:hackney, "~> 1.20"},
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Official Elixir SDK for interacting with the Knock API."
  end

  defp package do
    [
      maintainers: ["Knock Team"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md", "LICENSE"]
    ]
  end
end
