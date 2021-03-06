defmodule OpenGraph.MixProject do
  use Mix.Project

  def project do
    [
      app: :ogp,
      version: "1.0.2",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],

      # Hex
      description: "The Open Graph protocol library in Elixir.",
      package: package(),
      docs: docs()
    ]
  end

  defp package do
    [
      name: "ogp",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/goofansu/ogp"},
      source_url: "https://github.com/goofansu/ogp",
      homepage_url: "https://github.com/goofansu/ogp"
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {OpenGraph.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:bypass, "~> 2.1", only: :test},
      {:excoveralls, "~> 0.10", only: :test},
      {:floki, "~> 0.27"},
      {:finch, "~> 0.6"}
    ]
  end
end
