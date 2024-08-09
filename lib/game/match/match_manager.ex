defmodule Game.Match.MatchManager do
  @moduledoc """
    This module is responsible for match manager.
  """

  use GenServer
  require Logger

  def start_link(_args) do
    case GenServer.start_link(__MODULE__, %{}, name: __MODULE__) do
      {:ok, pid} ->
        node = :erlang.node(pid)
        Logger.info("Match Manager started on #{node}")
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        node = :erlang.node(pid)
        Logger.warning("Match Manager already started on #{node}")
        {:ok, pid}
    end
  end

  def init(state) do
    {:ok, state}
  end

  def create_match(player_one, player_two) do
    GenServer.call(__MODULE__, {:create_match, player_one, player_two})
  end

  def handle_call({:create_match, player_one, player_two}, _from, state) do
    Game.Match.MatchSupervisor.start_match(player_one, player_two)
    {:reply, :ok, state}
  end
end
