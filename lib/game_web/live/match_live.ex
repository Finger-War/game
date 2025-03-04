defmodule GameWeb.MatchLive do
  use GameWeb, :live_view
  require Logger

  alias GameWeb.CoreComponents
  alias Game.Match.Match
  alias Game.HordeRegistry

  @topic "game:match"

  def mount(params, session, socket) do
    player_id = Map.get(params, "player_id") || Map.get(session, "player_id")
    Logger.info("Mounting MatchLive with player_id: #{player_id}")

    default_words = ["waiting", "for", "match", "to", "start"]

    current_player =
      if player_id do
        %{id: player_id, words: [], current_word: "", score: 0}
      else
        nil
      end

    if connected?(socket) do
      Logger.info("Socket connected for player #{player_id}")

      GameWeb.Endpoint.subscribe(@topic)

      if player_id do
        player_topic = "player:#{player_id}"
        GameWeb.Endpoint.subscribe(player_topic)
        Logger.info("Subscribed to player topic: #{player_topic}")

        check_ongoing_match(player_id)
      end

      if player_id do
        Logger.info("Broadcasting player_joined for #{player_id}")
        GameWeb.Endpoint.broadcast(@topic, "player_joined", %{player_id: player_id})
      end

      Process.send_after(self(), :check_match_progress, 3000)
    end

    socket =
      assign(socket,
        words: default_words,
        player_one: %{id: nil, words: [], current_word: "", score: 0},
        player_two: %{id: nil, words: [], current_word: "", score: 0},
        current_player: current_player,
        opponent: nil,
        current_input: "",
        match_status: :waiting,
        time_remaining: 60,
        is_player_one: true,
        debug_info: "Waiting for match data...",
        is_winner: false,
        is_draw: false,
        your_score: 0,
        opponent_score: 0
      )

    {:ok, socket}
  end

  def handle_info({:notify_joined, player_id}, socket) do
    GameWeb.Endpoint.broadcast(@topic, "player_joined", %{player_id: player_id})
    {:noreply, socket}
  end

  def handle_info(%{event: "player_joined", payload: %{player_id: _player_id}}, socket) do
    {:noreply, socket}
  end

  def handle_info(%{event: "match_started", payload: payload}, socket) do
    Logger.info("Match started received with #{length(payload.words)} words")

    if Map.has_key?(payload, :words) do
      Logger.info("Words received: #{inspect(Enum.take(payload.words, 3))}...")
    else
      Logger.error("No words in match_started payload!")
    end

    current_player_id = socket.assigns.current_player

    is_player_one =
      if is_binary(current_player_id) do
        current_player_id == payload.player_one.id
      else
        current_player_id.id == payload.player_one.id
      end

    player_id_string =
      if is_map(current_player_id), do: current_player_id.id, else: current_player_id

    if is_player_one do
      Logger.info("Player #{player_id_string} identified as player_one")
    else
      Logger.info("Player #{player_id_string} identified as player_two")
    end

    {current_player, opponent} =
      if is_player_one do
        {payload.player_one, payload.player_two}
      else
        {payload.player_two, payload.player_one}
      end

    words =
      case payload do
        %{words: words} when is_list(words) and length(words) > 0 ->
          Logger.info("Using #{length(words)} words from payload")
          words

        _ ->
          Logger.warning("No words in payload, using fallback words")
          ["elixir", "phoenix", "liveview", "javascript", "erlang"]
      end

    {:noreply,
     assign(socket,
       words: words,
       player_one: payload.player_one,
       player_two: payload.player_two,
       current_player: current_player,
       opponent: opponent,
       is_player_one: is_player_one,
       match_status: :playing,
       debug_info: "Match started with #{length(words)} words"
     )}
  end

  def handle_info(%{event: "match_update", payload: payload}, socket) do
    Logger.debug("Match update received: #{inspect(payload)}")

    is_player_one = Map.get(socket.assigns, :is_player_one, true)

    {current_player, opponent} =
      if is_player_one do
        {payload.player_one, payload.player_two}
      else
        {payload.player_two, payload.player_one}
      end

    {:noreply,
     assign(socket,
       player_one: payload.player_one,
       player_two: payload.player_two,
       current_player: current_player,
       opponent: opponent
     )}
  end

  def handle_info(%{event: "match_finished", payload: payload}, socket) do
    Logger.info("Match finished event received: #{inspect(payload)}")

    winner = Map.get(payload, :winner, :draw)
    reason = Map.get(payload, :reason, "normal")

    current_player_id =
      if is_map(socket.assigns.current_player) do
        socket.assigns.current_player.id
      else
        socket.assigns.current_player
      end

    winner_id = if is_map(winner), do: winner.id, else: nil
    is_draw = winner == :draw
    is_winner = not is_draw and winner_id == current_player_id

    your_score =
      if is_map(socket.assigns.current_player) and is_list(socket.assigns.current_player.words) do
        length(socket.assigns.current_player.words)
      else
        0
      end

    opponent_score =
      if is_map(socket.assigns.opponent) and is_list(socket.assigns.opponent.words) do
        length(socket.assigns.opponent.words)
      else
        0
      end

    winner_message =
      case {reason, is_draw, is_winner} do
        {_, true, _} ->
          "It's a draw! Both players tied with #{your_score} words."

        {"time_up", _, true} ->
          "Time's up! You won by typing #{your_score} words!"

        {"time_up", _, false} ->
          "Time's up! Opponent won by typing #{opponent_score} words."

        {_, _, true} ->
          "You won by typing #{your_score} words!"

        {_, _, false} ->
          "Opponent won by typing #{opponent_score} words."
      end

    Logger.info("Match ended: #{winner_message}")

    status =
      cond do
        is_winner -> "victory"
        is_draw -> "draw"
        true -> "defeat"
      end

    socket = push_event(socket, "match_ended", %{status: status})

    {:noreply,
     socket
     |> assign(
       match_status: :finished,
       winner: winner,
       winner_message: winner_message,
       is_winner: is_winner,
       is_draw: is_draw,
       your_score: your_score,
       opponent_score: opponent_score
     )}
  end

  def handle_info(%{event: "timer_update", payload: %{time_remaining: time}}, socket) do
    Logger.debug("Timer update: #{time}s remaining")

    socket = if time == 10, do: push_event(socket, "time_warning", %{}), else: socket

    updated_socket =
      if socket.assigns.match_status == :waiting do
        Logger.info("Received timer updates while in waiting state - transitioning to playing")
        assign(socket, match_status: :playing)
      else
        socket
      end

    if time <= 0 and socket.assigns.match_status == :playing do
      Logger.info("Timer reached zero - ending match and redirecting soon")

      Process.send_after(self(), :ensure_redirect, 2000)
    end

    {:noreply, assign(updated_socket, time_remaining: time)}
  end

  def handle_info(:ensure_redirect, socket) do
    if socket.assigns.match_status == :playing do
      Logger.warning("No match_finished event received, forcing redirect")

      {:noreply,
       socket
       |> assign(match_status: :finished, winner_message: "Time's up! Match ended.")
       |> push_navigate(to: "/")}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{event: "timer_update", payload: %{time_remaining: time}}, socket) do
    if time <= 0 and socket.assigns.match_status == :playing do
      Logger.info("Timer reached zero - match should end soon")
    end

    {:noreply, assign(socket, time_remaining: time)}
  end

  def handle_info(:check_match_progress, socket) do
    if socket.assigns.match_status == :waiting and length(socket.assigns.words) > 0 and
         socket.assigns.words != ["waiting", "for", "match", "to", "start"] do
      Logger.info("Auto-transitioning to playing state - match appears to have started")

      {:noreply, assign(socket, match_status: :playing)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("type", %{"word" => word}, socket) when word != "" do
    player_id =
      if is_map(socket.assigns.current_player) do
        socket.assigns.current_player.id
      else
        socket.assigns.current_player
      end

    Logger.debug("Player #{player_id} typing: #{word}")

    case Game.Match.Match.type_word(player_id, word) do
      {:ok, _} ->
        socket = push_event(socket, "word_result", %{result: "correct"})
        {:noreply, assign(socket, current_input: "")}

      {:error, reason} ->
        Logger.debug("Error typing word: #{inspect(reason)}")
        socket = push_event(socket, "word_result", %{result: "incorrect"})
        {:noreply, socket}
    end
  end

  def handle_event("type", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("input_change", %{"word" => word}, socket) do
    {:noreply, assign(socket, current_input: word)}
  end

  def handle_event("redirect", _, socket) do
    Logger.info("User clicked 'Voltar à página inicial' button")
    {:noreply, push_navigate(socket, to: "/")}
  end

  def handle_event("debug_info", _, socket) do
    player_id =
      if is_map(socket.assigns.current_player) do
        socket.assigns.current_player.id
      else
        socket.assigns.current_player
      end

    debug = %{
      player_id: player_id,
      is_player_one: socket.assigns.is_player_one,
      match_status: socket.assigns.match_status,
      word_count: length(socket.assigns.words),
      time: socket.assigns.time_remaining
    }

    Logger.info("Debug info: #{inspect(debug)}")

    {:noreply, socket}
  end

  defp determine_current_player(_socket, player_one, _player_two) do
    player_one.id
  end

  defp check_ongoing_match(player_id) do
    case Game.HordeRegistry.lookup_player(player_id) do
      {:ok, match_pid} ->
        Logger.info("Found ongoing match for player #{player_id}")

        try do
          GenServer.call(match_pid, :get_state)
        catch
          :exit, _ -> Logger.warning("Could not get match state")
        end

      _ ->
        Logger.info("No ongoing match found for player #{player_id}")
    end
  end
end
