defmodule ValorantStoreBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: ValorantStoreBot.Worker.start_link(arg)
      # {ValorantStoreBot.Worker, arg}
      Nosedrum.Storage.ETS,
      {Nosedrum.Interactor.Dispatcher, name: Nosedrum.Interactor.Dispatcher},
      {ValorantStoreBot, restart: :permanent},
      {ValorantStoreBot.Repo, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ValorantStoreBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
