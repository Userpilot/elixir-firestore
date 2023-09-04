defmodule Firestore.MixProject do
  use Mix.Project

  def project do
    [
      app: :firestore,
      description:
        "An abstraction over Google's Firestore API for convenience and configurability.",
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # ExDoc configurations
      name: "Elixir Firestore",
      source_url: "https://github.com/userpilot/elixir-firestore",
      docs: [
        main: "README",
        extras: ["README.md"]
      ],

      # Dialyzer configurations
      dialyzer: [
        list_unused_filters: true,
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger,:ibrowse]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:google_api_firestore, "~> 0.22"},
      {:cowlib, "~> 2.6"},
      {:goth, "~> 1.3"},
      {:tesla, "~> 1.4.0"},
      {:hackney, "~> 1.10"},
      {:gun, "~> 1.3"},
      {:mint, "~> 1.0"},
      {:finch, "~> 0.14.0"},
      {:ibrowse, "~> 4.2"},
      {:idna, "~> 6.0"},
      {:castore, "~> 0.1"},
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:git_hooks, "~> 0.7.0", only: :dev, runtime: false}
    ]
  end
end
