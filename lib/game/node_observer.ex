defmodule Game.NodeObserver do
  @moduledoc """
    This module is responsible for observing node up and down events.
  """

  use GenServer

  alias Game.{HordeRegistry, HordeSupervisor}

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_) do
    :net_kernel.monitor_nodes(true, node_type: :visible)

    {:ok, nil}
  end

  def handle_info({:nodeup, _node, _node_type}, state) do
    set_members(HordeRegistry)
    set_members(HordeSupervisor)

    {:noreply, state}
  end

  def handle_info({:nodedown, _node, _node_type}, state) do
    set_members(HordeRegistry)
    set_members(HordeSupervisor)

    {:noreply, state}
  end

  defp set_members(name) do
    members = Enum.map([Node.self() | Node.list()], &{name, &1})

    :ok = Horde.Cluster.set_members(name, members)
  end
end
