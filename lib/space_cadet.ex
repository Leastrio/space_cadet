defmodule SpaceCadet.Bot do
  def start_link(opts) do

  end
end

defmodule SpaceCadet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {SpaceCadet.Gateway, token: "" }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SpaceCadet.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
