defmodule GameWeb.QueueChannel do
  alias Game.Queue.QueueManager
  use GameWeb, :channel

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
