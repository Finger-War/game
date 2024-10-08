defmodule Game.Application do
  @moduledoc """
    This module is responsible for game application start.
  """

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: Game.ClusterSupervisor]]},
      {Horde.Registry, [name: Game.HordeRegistry, keys: :unique]},
      {Horde.DynamicSupervisor, [name: Game.HordeSupervisor, strategy: :one_for_one]},
      {Game.NodeObserver, []},
      GameWeb.Endpoint,
      {Game.Match.MatchSupervisor, []},
      {Game.Match.MatchManager, []},
      {Phoenix.PubSub, name: Game.PubSub},
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

  @impl true
  def start_phase(:queue_phase, _start_type, _args) do
    :timer.sleep(:rand.uniform(1000))

    case :global.whereis_name(Game.Queue.QueueSupervisor) do
      :undefined ->
        Horde.DynamicSupervisor.start_child(Game.HordeSupervisor, Game.Queue.QueueSupervisor)

      pid ->
        node = :erlang.node(pid)
        Logger.warning("Queue supervisor already started: #{node}")
    end

    :ok
  end
end
