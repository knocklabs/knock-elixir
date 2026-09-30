defmodule Knock.MixProject do
  use Mix.Project

  @source_url "https://github.com/knocklabs/knock-elixir"
  @version "0.6.0"

  def project do
    [
      app: :knock,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      extra_applications: [:logger],
      mod: {Knock.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:finch, "~> 0.13"},
      {:jason, "~> 1.1"},
      {:jose, "~> 1.11", optional: true},
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
      extras: ["README.md", "LICENSE"],
      groups_for_modules: [
        Client: [Knock, Knock.Client, Knock.Api, Knock.Response],
        Resources: [
          Knock.Audiences,
          Knock.BulkOperations,
          Knock.Channels,
          Knock.Messages,
          Knock.Objects,
          Knock.Schedules,
          Knock.Tenants,
          Knock.Users,
          Knock.WorkflowRecipientRuns,
          Knock.Workflows
        ],
        Providers: [Knock.Providers.Slack, Knock.Providers.MsTeams],
        Integrations: [Knock.Integrations.Census, Knock.Integrations.Hightouch],
        Authentication: [Knock.UserTokens],
        Deprecated: [Knock.Preferences]
      ]
    ]
  end
end
