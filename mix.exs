defmodule PhStTransform.Mixfile do
  use Mix.Project

  def project do
    [app: :phst_transform,
     version: "1.0.2",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     # Ex_doc
     docs: [logo: "examples/phst_svg.png",
          extras: ["README.md", "EXAMPLES.md"]],

     # Hex
     package: hex_package(),
     description: description()

     ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    []
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:credo, "~> 0.1.9", only: :dev},
     {:ex_doc, "~> 0.5", only: :dev}]
  end


  defp description do
    """
    An Elixir Protocol and implementation for creating a tranform of any elixir data.
    """
  end

  defp hex_package do
    [# These are the default files included in the package
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Booker C. Bense"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/philosophers-stone/transform",
              "Docs" => "http://hexdocs.pm/phst_transform/api-reference.html"}]
  end
end
