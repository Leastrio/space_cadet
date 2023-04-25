defmodule SpaceCadet.MixProject do
  use Mix.Project

  def project do
    [
      app: :space_cadet,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A discord wrapper for elixir",
      package: package(),
      name: "Space Cadet",
      source_url: "https://github.com/Leastrio/space_cadet"
    ]
  end

  def package do
    [
      name: :space_cadet,
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/Leastrio/space_cadet"
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SpaceCadet.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:finch, "~> 0.16"},
      {:ecto, "~> 3.8"},
      {:mint_web_socket, "~> 1.0"},
      {:castore, "~> 1.0"},
      {:mint, "~> 1.0"},
      {:gen_stage, "~> 1.0.0"},
    ]
  end
end
