defmodule Game.Match.MatchRegistry do
  def start_link(_args) do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def register_player(player, match_pid) do
    Registry.register(__MODULE__, player, match_pid)
  end

  def get_match_pid_by_player(player) do
    case Registry.lookup(__MODULE__, player) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end
end
