defmodule Game.Match.Match do
  @moduledoc """
    This module is responsible for match.
  """

  alias Game.Match.MatchSupervisor

  use GenServer

  @duration 60_000

  def start_link({player_one, player_two}) do
    GenServer.start_link(__MODULE__, {player_one, player_two}, name: via(player_one, player_two))
  end

  defp via(player_one, player_two) do
    {:via, Registry, {Game.Match.Registry, {player_one, player_two}}}
  end

  def init({player_one, player_two}) do
    IO.puts("Match started between #{player_one} and #{player_two}")
    schedule()

    {:ok,
     %{
       start_time: :os.system_time(:millisecond),
       player_one: player_one,
       player_two: player_two,
       words: [],
       result: %{}
     }}
  end

  defp schedule do
    Process.send_after(self(), :finish, @duration)
  end

  def handle_info(:finish, state) do
    IO.puts("Match finished between #{state.player_one} and #{state.player_two}")
    IO.puts("Result: #{inspect(state.result)}")

    MatchSupervisor.stop_match(self())

    {:stop, :normal, state}
  end

  def handle_call({:add_word, player, word}, _from, state) do
    words = state.words ++ [{player, word}]

    {:reply, :ok, %{state | words: words}}
  end
end
