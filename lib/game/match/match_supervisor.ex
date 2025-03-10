defmodule Game.Match.MatchSupervisor do
  @moduledoc """
  Distributed supervisor for match processes across the cluster.
  """

  use Horde.DynamicSupervisor
  require Logger

  def start_link(_) do
    Horde.DynamicSupervisor.start_link(__MODULE__, [strategy: :one_for_one], name: __MODULE__)
  end

  def init(args) do
    [members: members()]
    |> Keyword.merge(args)
    |> Horde.DynamicSupervisor.init()
  end

  def members() do
    [Node.self() | Node.list()]
    |> Enum.map(fn node -> {__MODULE__, node} end)
  end

  def start_match(player_one, player_two) do
    Logger.info("Starting match between #{player_one} and #{player_two}")
    child_spec = {Game.Match.Match, {player_one, player_two}}
    Horde.DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def stop_match(pid) when is_pid(pid) do
    Logger.info("Stopping match process #{inspect(pid)}")
    Horde.DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def delete_match(player_one, player_two) do
    Logger.info("Deleting match between #{player_one} and #{player_two}")

    key = {:match, player_one, player_two}

    case Horde.Registry.lookup(Game.HordeRegistry, key) do
      [{pid, _}] ->
        Logger.info("Found match process, terminating: #{inspect(pid)}")
        stop_match(pid)

      [] ->
        Logger.warning("Match not found in registry: #{player_one}-#{player_two}")
        :not_found
    end
  end

  def handle_topology_change(nodes) do
    Logger.info("Topology change detected: #{inspect(nodes)}")
    set_members(members())
  end

  def set_members(members) do
    Horde.Cluster.set_members(__MODULE__, members)
  end
end
