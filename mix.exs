defmodule ARQ.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :arq,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: "Dead simple Automatic Request Repeat for independent messages.",
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [],
      mod: {ARQ.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [maintainers: ["Michael Shapiro"],
     licenses: ["MIT"],
     links: %{"GitHub": "https://github.com/chassisframework/arq"}]
  end

  defp docs do
    [extras: ["README.md"],
     source_url: "https://github.com/chassisframework/arq",
     source_ref: @version,
     assets: "assets",
     main: "readme"]
  end
end
