defmodule Game.Match.MatchManager do
  @moduledoc """
    This module is responsible for match manager.
  """

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
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
