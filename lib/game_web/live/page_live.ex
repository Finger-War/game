defmodule GameWeb.PageLive do
  use GameWeb, :live_view

  alias GameWeb.CoreComponents
  alias Phoenix.PubSub
  alias Game.Queue.QueueManager

  def mount(_params, _session, socket) do
    {:ok, assign(socket, in_queue: false, player_id: nil)}
  end

  def handle_event("join_queue", _params, socket) do
    player_id = "player_" <> :crypto.strong_rand_bytes(4) |> Base.encode16()

    QueueManager.add_to_queue(player_id)

    {:noreply, assign(socket, in_queue: true, player_id: player_id)}
  end

  def handle_event("leave_queue", _params, socket) do
    player_id = socket.assigns.player_id

    QueueManager.remove_from_queue(player_id)

    {:noreply, assign(socket, in_queue: false, player_id: nil)}
  end
end
