defmodule GameWeb.PageLive do
  use GameWeb, :live_view
  require Logger

  alias Game.Queue.QueueManager

  @topic "game:queue"
  @cluster_topic "cluster:status"

  def mount(_params, _session, socket) do
    queue_count =
      try do
        length(QueueManager.list_queue())
      rescue
        _ -> 0
      end

    if connected?(socket) do
      GameWeb.Endpoint.subscribe(@topic)
      GameWeb.Endpoint.subscribe(@cluster_topic)
      GameWeb.Endpoint.broadcast(@topic, "queue_update", %{count: queue_count})
    end

    {:ok,
     assign(socket,
       in_queue: false,
       player_id: nil,
       match_started: false,
       queue_count: queue_count
     )}
  end

  def handle_event("join_queue", _params, socket) do
    player_id = ("player_" <> :crypto.strong_rand_bytes(4)) |> Base.encode16()
    QueueManager.add_to_queue(player_id)
    queue_count = length(QueueManager.list_queue())
    GameWeb.Endpoint.broadcast(@topic, "queue_update", %{count: queue_count})
    {:noreply, assign(socket, in_queue: true, player_id: player_id, queue_count: queue_count)}
  end

  def handle_event("leave_queue", _params, socket) do
    player_id = socket.assigns.player_id
    QueueManager.remove_from_queue(player_id)
    queue_count = length(QueueManager.list_queue())
    GameWeb.Endpoint.broadcast(@topic, "queue_update", %{count: queue_count})
    {:noreply, assign(socket, in_queue: false, player_id: nil, queue_count: queue_count)}
  end

  def handle_info(
        %{event: "match_started", payload: %{player_one: player_one, player_two: player_two}},
        socket
      ) do
    current_player = socket.assigns.player_id

    if current_player in [player_one, player_two] do
      {:noreply,
       socket
       |> assign(match_started: true)
       |> redirect(to: ~p"/match/#{current_player}")}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{event: "queue_update", payload: %{count: count}}, socket) do
    {:noreply, assign(socket, queue_count: count)}
  end

  def handle_info(%{event: "node_change"}, socket) do
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    if socket.assigns.player_id do
      player_id = socket.assigns.player_id

      if socket.assigns.in_queue do
        QueueManager.remove_from_queue(player_id)
        queue_count = length(QueueManager.list_queue())
        GameWeb.Endpoint.broadcast(@topic, "queue_update", %{count: queue_count})
      end
    end

    GameWeb.Endpoint.unsubscribe(@topic)
    GameWeb.Endpoint.unsubscribe(@cluster_topic)
    :ok
  end
end
