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
    player_one_in_match = Game.HordeRegistry.lookup_player(player_one) != :error
    player_two_in_match = Game.HordeRegistry.lookup_player(player_two) != :error

    cond do
      player_one_in_match ->
        Logger.warning("Player #{player_one} is already in a match. Skipping match creation.")
        {:reply, {:error, :player_already_in_match}, state}

      player_two_in_match ->
        Logger.warning("Player #{player_two} is already in a match. Skipping match creation.")
        {:reply, {:error, :player_already_in_match}, state}

      true ->
        result = Game.Match.MatchSupervisor.start_match(player_one, player_two)

        case result do
          {:ok, _pid} ->
            Logger.info("Successfully created match between #{player_one} and #{player_two}")
            {:reply, result, state}

          error ->
            Logger.error("Failed to create match: #{inspect(error)}")
            {:reply, error, state}
        end
    end
  end
end
