defmodule OpenGraph.MixProject do
  use Mix.Project

  def project do
    [
      app: :ogp,
      version: "1.1.2",
      elixir: "~> 1.13",
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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5"},
      {:floki, "~> 0.35"},
      {:plug, "~> 1.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18.2", only: :test},
      {:castore, "~> 1.0", only: :test}
    ]
  end
end
