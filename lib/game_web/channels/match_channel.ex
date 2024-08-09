defmodule GameWeb.MatchChannel do
  @moduledoc """
    This module is responsible for match channel.
  """

  alias Game.HordeRegistry
  alias Game.Match.Match

  use GameWeb, :channel

  @impl true
  def join("match:lobby", _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("new_word", %{"player" => player, "word" => word}, socket) do
    match_pid = HordeRegistry.get_match_pid_by_player(player)
    Match.add_word(match_pid, player, word)

    {:noreply, socket}
  end
end
