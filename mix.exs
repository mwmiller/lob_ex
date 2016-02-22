defmodule Lob.Mixfile do
  use Mix.Project

  def project do
    [app: :lob,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    [
    {:poison, "~> 2.1"},
    {:power_assert, "~> 0.0.8", only: :test},
    ]
  end
end
