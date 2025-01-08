defmodule GameWeb.PageLive do
  use GameWeb, :live_view

  alias GameWeb.CoreComponents
  alias Game.Queue.QueueManager

  @topic "game:queue"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      GameWeb.Endpoint.subscribe(@topic)
    end

    {:ok, assign(socket, in_queue: false, player_id: nil, match_started: false)}
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

  def handle_info(%{event: "match_started", payload: %{player_one: player_one, player_two: player_two}}, socket) do
    current_player = socket.assigns.player_id

    if current_player in [player_one, player_two] do
      {:noreply, socket |> assign(match_started: true) |> redirect(to: ~p"/match")}
    else
      {:noreply, socket}
    end
  end
end
