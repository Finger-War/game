defmodule Game.Match.MatchRegistry do
  def start_link(_args) do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end
end
