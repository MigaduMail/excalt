defmodule Excalt.MixProject do
  use Mix.Project

  def project do
    [
      app: :excalt,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      name: "Excalt",
      package: package(),
      deps: deps(),
      docs: [
        source_ref: "v#{@version}",
        main: "MIME",
        source_url: "https://github.com/Advite/excalt"
      ]
    ]
  end

  def package do
    [
      maintainers: ["swerter", "Michael Bruderer"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/Advite/excalt"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Excalt.Application, []}
    ]
  end

  defp description() do
    "Another CalDav client library"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:saxy, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:ex_doc, ">= 0.29.0", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false}
    ]
  end
end
