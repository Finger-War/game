defmodule Game.Application do
  @moduledoc """
    This module is responsible for game application start.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GameWeb.Endpoint,
      Game.Queue.QueueSupervisor,
      {DNSCluster, query: Application.get_env(:game, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Game.PubSub},
      {Finch, name: Game.Finch},
      GameWeb.Telemetry
    ]

    opts = [strategy: :one_for_one, name: Game.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
