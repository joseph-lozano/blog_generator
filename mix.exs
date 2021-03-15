defmodule Blog.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :blog,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_options: elixirc_options(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix, :eex]]
    ]
  end

  defp elixirc_options(:dev), do: []
  defp elixirc_options(_), do: [warnings_as_errors: true]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Blog.Application, []},
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4"},
      {:yaml_elixir, "~> 2.6"},
      {:typed_struct, "~> 0.2.1"},
      {:plug_cowboy, "~> 2.0", only: [:dev]}
    ]
  end
end
