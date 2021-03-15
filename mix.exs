defmodule BlogGenerator.MixProject do
  use Mix.Project

  def project do
    [
      app: :blog_generator,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
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
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:eex_html, "~> 1.0"},
      {:earmark, "~> 1.4"},
      {:yaml_elixir, "~> 2.6"},
      {:typed_struct, "~> 0.2.1"}
    ]
  end
end
