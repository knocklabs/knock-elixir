defmodule Knock.MixProject do
  use Mix.Project

  def project do
    [
      app: :knock,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      name: "Knock",
      deps: deps(),
      source_url: "https://github.com/knocklabs/knock-elixir"
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
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Official Elixir SDK for interacting with the Knock API."
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/knocklabs/knock-elixir"}
    ]
  end
end
