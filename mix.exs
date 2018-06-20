defmodule Deque.Mixfile do
  use Mix.Project

  def project do
    [
      app: :deque,
      version: "1.1.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:benchfella, "~> 0.3.5", only: :dev}
    ]
  end

  def package do
    [
      name: :deque,
      description: "Fast bounded deque using two rotating lists.",
      maintainers: [],
      licenses: ["MIT"],
      files: ["lib/*", "mix.exs", "README*", "LICENSE*"],
      links: %{
        "GitHub" => "https://github.com/discordapp/deque",
      },
    ]
  end
end
