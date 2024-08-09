defmodule Game.Match.Match do
  @moduledoc """
    This module is responsible for match.
  """

  use GenServer
  require Logger

  alias Game.Match.MatchSupervisor
  alias Game.HordeRegistry

  @duration 60_000

  def start_link({player_one, player_two}) do
    case GenServer.start_link(__MODULE__, {player_one, player_two},
           name: via_tuple(player_one, player_two)
         ) do
      {:ok, pid} ->
        node = :erlang.node(pid)
        Logger.info("Match started on #{node}")

      {:error, {:already_started, pid}} ->
        node = :erlang.node(pid)
        Logger.warning("Match already started on #{node}")
    end
  end

  def init({player_one, player_two}) do
    HordeRegistry.register_player(player_one, self())
    HordeRegistry.register_player(player_two, self())

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

  defp via_tuple(player_one, player_two) do
    {:via, Horde.Registry, {HordeRegistry, {player_one, player_two}}}
  end

  def add_word(match_pid, player, word) do
    GenServer.call(match_pid, {:add_word, player, word})
  end

  def handle_call({:add_word, player, word}, _from, state) do
    words = state.words ++ [{player, word}]

    {:reply, :ok, %{state | words: words}}
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
end
