defmodule Lob.Mixfile do
  use Mix.Project

  def project do
    [
      app: :lob,
      version: "1.0.3",
      elixir: "~> 1.7",
      name: "Lob",
      source_url: "https://github.com/mwmiller/lob_ex",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:chacha20, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.23", only: :dev},
    ]
  end

  defp description do
    """
    Length-Object-Binary (LOB) Packet Encoding
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Matt Miller"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mwmiller/lob_ex"}
    ]
  end
end
