defmodule GameWeb.QueueChannel do
  @moduledoc """
    This module is responsible for queue channel.
  """

  use GameWeb, :channel

  alias Game.Queue.QueueManager

  @impl true
  def join("queue:lobby", _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("add_to_queue", %{"player_id" => player_id}, socket) do
    QueueManager.add_to_queue(player_id)

    {:noreply, socket}
  end

  def handle_in("remove_from_queue ", %{"player_id" => player_id}, socket) do
    QueueManager.remove_from_queue(player_id)

    {:noreply, socket}
  end
end
