defmodule Game.Match.MatchSupervisor do
  @moduledoc """
    This module is responsible for match supervisor.
  """

  use Horde.DynamicSupervisor

  def start_link(_) do
    Horde.DynamicSupervisor.start_link(__MODULE__, [strategy: :one_for_one], name: __MODULE__)
  end

  def init(args) do
    [members: members()]
    |> Keyword.merge(args)
    |> Horde.DynamicSupervisor.init()
  end

  def start_match(player_one, player_two) do
    Horde.DynamicSupervisor.start_child(__MODULE__, {Game.Match.Match, {player_one, player_two}})
  end

  def stop_match(pid) do
    Horde.DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  defp members() do
    Enum.map([Node.self() | Node.list()], &{__MODULE__, &1})
  end
end
