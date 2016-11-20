defmodule Lob.Mixfile do
  use Mix.Project

  def project do
    [app: :lob,
     version: "0.1.3",
     elixir: "~> 1.3",
     name: "Lob",
     source_url: "https://github.com/mwmiller/lob_ex",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps,
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:chacha20, "~> 0.3"},
      {:poison, "~> 3.0"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev},
    ]
  end

  defp description do
    """
    Length-Object-Binary (LOB) Packet Encoding
    """
  end

  defp package do
    [
     files: ["lib", "mix.exs", "README*", "LICENSE*", ],
     maintainers: ["Matt Miller"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mwmiller/lob_ex",}
    ]
  end

end
