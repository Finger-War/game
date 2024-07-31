defmodule Game.Match.MatchSupervisor do
  @moduledoc """
    This module is responsible for match supervisor.
  """

  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_match(player_one, player_two) do
    DynamicSupervisor.start_child(__MODULE__, {Game.Match.Match, {player_one, player_two}})
  end

  def stop_match(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end
end
