defmodule Game.HordeRegistry do
  @moduledoc """
    This module is responsible for game horde registry.
  """

  use Horde.Registry

  def start_link(_) do
    Horde.Registry.start_link(__MODULE__, [keys: :unique], name: __MODULE__)
  end

  def init(args) do
    [members: members()]
    |> Keyword.merge(args)
    |> Horde.Registry.init()
  end

  def register_player(player, match_pid) do
    Horde.Registry.register(__MODULE__, player, match_pid)
  end

  def get_match_pid_by_player(player) do
    case Horde.Registry.lookup(__MODULE__, player) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end

  defp members() do
    Enum.map([Node.self() | Node.list()], &{__MODULE__, &1})
  end
end
