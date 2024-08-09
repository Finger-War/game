defmodule Game.Queue.Queue do
  @moduledoc """
    This module is responsible for queue.
  """

  use GenServer
  require Logger

  alias Game.Queue.QueueManager
  alias Game.Match.MatchManager

  @interval 1000

  def start_link(_args) do
    case GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__}) do
      {:ok, pid} ->
        node = :erlang.node(pid)
        Logger.info("Queue started on #{node}")
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        node = :erlang.node(pid)
        Logger.warning("Queue already started on #{node}")
        {:ok, pid}
    end
  end

  def init(state) do
    schedule()
    {:ok, state}
  end

  def handle_info(:queue_match, state) do
    generate_queue_matches()

    schedule()
    {:noreply, state}
  end

  defp generate_queue_matches do
    case select_two_players_from_queue() do
      {:ok, {player_one, player_two}} ->
        MatchManager.create_match(player_one, player_two)

        generate_queue_matches()

      :error ->
        :noop
    end
  end

  defp select_two_players_from_queue do
    queue = QueueManager.list_queue()

    case queue do
      [player_one, player_two | _] ->
        QueueManager.remove_from_queue(player_one)
        QueueManager.remove_from_queue(player_two)
        {:ok, {player_one, player_two}}

      _ ->
        :error
    end
  end

  defp schedule do
    Process.send_after(self(), :queue_match, @interval)
  end
end
