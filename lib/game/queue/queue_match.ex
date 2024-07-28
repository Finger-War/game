defmodule Game.Queue.QueueMatch do
  use GenServer

  @interval 1000

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  def init(state) do
    schedule_queue_match()
    {:ok, state}
  end

  def handle_info(:queue_match, state) do
    generate_queue_matches()

    schedule_queue_match()
    {:noreply, state}
  end

  defp generate_queue_matches do
    case select_two_players_from_queue() do
      {:ok, {player_one, player_two}} ->
        IO.puts("Match between #{player_one} and #{player_two}")

        generate_queue_matches()

      :error ->
        :noop
    end
  end

  defp select_two_players_from_queue do
    queue = Game.Queue.QueueManager.list_queue()

    case queue do
      [player_one, player_two | _] ->
        Game.Queue.QueueManager.remove_from_queue(player_one)
        Game.Queue.QueueManager.remove_from_queue(player_two)
        {:ok, {player_one, player_two}}

      _ ->
        :error
    end
  end

  defp schedule_queue_match do
    Process.send_after(self(), :queue_match, @interval)
  end
end
