defmodule Game.Match.Match do
  @moduledoc """
    This module is responsible for match.
  """

  use GenServer
  require Logger

  alias Game.Match.MatchSupervisor
  alias Game.HordeRegistry

  @duration 60_000
  @timer_interval 1000
  @topic "game:match"

  @words [
    "ability",
    "about",
    "above",
    "accept",
    "according",
    "account",
    "across",
    "action",
    "activity",
    "actually",
    "address",
    "administration",
    "admit",
    "adult",
    "affect",
    "after",
    "again",
    "against",
    "agency",
    "agent",
    "agree",
    "ahead",
    "allow",
    "almost",
    "alone",
    "along",
    "already",
    "although",
    "always",
    "American",
    "among",
    "amount",
    "analysis",
    "animal",
    "another",
    "answer",
    "anyone",
    "anything",
    "appear",
    "apply",
    "approach",
    "argue",
    "around",
    "arrive",
    "article",
    "artist",
    "assume",
    "attack",
    "attention",
    "attorney",
    "audience",
    "author",
    "authority",
    "available",
    "avoid",
    "award",
    "beautiful",
    "because",
    "become",
    "before",
    "begin",
    "behavior",
    "behind",
    "believe",
    "benefit",
    "better",
    "between",
    "beyond",
    "board",
    "build",
    "business",
    "camera",
    "campaign",
    "career",
    "carry",
    "center",
    "central",
    "century",
    "certain",
    "certainly",
    "chance",
    "change",
    "character",
    "charge",
    "check",
    "choice",
    "choose",
    "church",
    "citizen",
    "clearly",
    "close",
    "collection",
    "college",
    "commercial",
    "common",
    "community",
    "company",
    "compare",
    "complete",
    "concern",
    "condition",
    "consider",
    "consumer",
    "contain",
    "continue",
    "control",
    "could",
    "country",
    "couple",
    "course",
    "create",
    "cultural",
    "culture",
    "current",
    "customer",
    "daughter",
    "debate",
    "decade",
    "decide",
    "decision",
    "defense",
    "degree",
    "democratic",
    "describe",
    "design",
    "despite",
    "detail",
    "determine",
    "develop",
    "difference",
    "different",
    "difficult",
    "dinner",
    "direction",
    "director",
    "discover",
    "discuss",
    "discussion",
    "disease",
    "doctor",
    "during",
    "early",
    "economic",
    "economy",
    "education",
    "effect",
    "effort",
    "eight",
    "either",
    "election",
    "employee",
    "energy",
    "enjoy",
    "enough",
    "enter",
    "entire",
    "environment",
    "especially",
    "establish",
    "evening",
    "every",
    "everybody",
    "everyone",
    "everything",
    "evidence",
    "exactly",
    "example",
    "executive",
    "exist",
    "expect",
    "experience",
    "expert",
    "explain",
    "factor",
    "family",
    "father",
    "federal",
    "feeling",
    "field",
    "figure",
    "final",
    "finally",
    "financial",
    "finish",
    "first",
    "floor",
    "focus",
    "follow",
    "force",
    "foreign",
    "forget",
    "former",
    "forward",
    "friend",
    "front",
    "future",
    "garden",
    "general",
    "generation",
    "glass",
    "great",
    "green",
    "ground",
    "group",
    "growth",
    "guess",
    "happen",
    "happy",
    "health",
    "heart",
    "heavy",
    "history",
    "hospital",
    "hotel",
    "house",
    "however",
    "human",
    "hundred",
    "husband",
    "identify",
    "image",
    "imagine",
    "impact",
    "important",
    "improve",
    "include",
    "including",
    "increase",
    "indeed",
    "indicate",
    "individual",
    "industry",
    "information",
    "inside",
    "instead",
    "institution",
    "interest",
    "interesting",
    "international",
    "interview",
    "investment",
    "involve",
    "issue",
    "itself",
    "joint",
    "journal",
    "judge",
    "justice",
    "keep",
    "knowledge",
    "language",
    "large",
    "later",
    "laugh",
    "lawyer",
    "leader",
    "learn",
    "least",
    "leave",
    "legal",
    "letter",
    "level",
    "light",
    "likely",
    "listen",
    "little",
    "local",
    "longer",
    "machine",
    "magazine",
    "maintain",
    "major",
    "majority",
    "manage",
    "management",
    "manager",
    "market",
    "marriage",
    "material"
  ]

  def start_link({player_one, player_two}) do
    case GenServer.start_link(__MODULE__, {player_one, player_two},
           name: via_tuple(player_one, player_two)
         ) do
      {:ok, pid} ->
        node = :erlang.node(pid)
        Logger.info("Match started on #{node}")
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        node = :erlang.node(pid)
        Logger.warning("Match already started on #{node}")
        {:error, {:already_started, pid}}
    end
  end

  def add_word(match_pid, player, word) do
    GenServer.call(match_pid, {:add_word, player, word})
  end

  def type_word(player_id, word) do
    case HordeRegistry.lookup_player(player_id) do
      {:ok, match_pid} ->
        try do
          GenServer.call(match_pid, {:type_word, player_id, word})
        catch
          :exit, _ -> {:error, :match_crashed}
        end

      _ ->
        {:error, :not_found}
    end
  end

  def init({player_one, player_two}) do
    if player_in_match?(player_one) do
      Logger.warning("Player #{player_one} is already in a match")
      {:stop, :player_already_in_match}
    else
      if player_in_match?(player_two) do
        Logger.warning("Player #{player_two} is already in a match")
        {:stop, :player_already_in_match}
      else
        Logger.info("Initializing match between #{player_one} and #{player_two}")

        HordeRegistry.register_player(player_one, self())
        HordeRegistry.register_player(player_two, self())

        word_list =
          case Enum.take_random(@words, 25) do
            [] -> Enum.take(@words, 25)
            list -> list
          end

        Logger.info("Generated word list: #{inspect(word_list)}")

        player_one_data = %{id: player_one, words: [], current_word: "", score: 0}
        player_two_data = %{id: player_two, words: [], current_word: "", score: 0}

        Logger.info("Broadcasting match_started event with #{length(word_list)} words")
        broadcast_match_started(player_one_data, player_two_data, word_list)

        schedule_timer()
        finish_timer = Process.send_after(self(), :finish, @duration)

        {:ok,
         %{
           start_time: :os.system_time(:millisecond),
           player_one: player_one_data,
           player_two: player_two_data,
           words: word_list,
           time_remaining: @duration,
           finish_timer: finish_timer
         }}
      end
    end
  end

  def handle_call({:add_word, player, word}, _from, state) do
    words = state.words ++ [{player, word}]
    {:reply, :ok, %{state | words: words}}
  end

  def handle_call({:type_word, player_id, word}, _from, state) do
    Logger.debug("Player #{player_id} typed: #{word}")

    if word in state.words do
      {player_key, player_data} = get_player(state, player_id)

      updated_player = %{
        player_data
        | words: [word | player_data.words],
          current_word: word,
          score: player_data.score + 1
      }

      new_state = Map.put(state, player_key, updated_player)

      Logger.debug("Broadcasting match update")

      GameWeb.Endpoint.broadcast(@topic, "match_update", %{
        player_one: new_state.player_one,
        player_two: new_state.player_two
      })

      {:reply, {:ok, :correct}, new_state}
    else
      Logger.debug("Invalid word: #{word}")
      {:reply, {:error, :invalid_word}, state}
    end
  end

  def handle_call(:get_state, _from, state) do
    if Map.has_key?(state, :player_one) && Map.has_key?(state, :player_two) do
      GameWeb.Endpoint.broadcast(@topic, "match_started", %{
        player_one: state.player_one,
        player_two: state.player_two,
        words: state.words
      })

      GameWeb.Endpoint.broadcast(@topic, "timer_update", %{
        time_remaining: div(state.time_remaining, 1000)
      })
    end

    {:reply, {:ok, state}, state}
  end

  def handle_info(:timer_tick, %{time_remaining: time} = state) when time > 0 do
    new_time = time - @timer_interval

    GameWeb.Endpoint.broadcast(@topic, "timer_update", %{
      time_remaining: div(new_time, 1000)
    })

    if rem(div(new_time, 1000), 10) == 0 do
      Logger.info("Match timer: #{div(new_time, 1000)}s remaining")
    end

    if new_time <= 5000 do
      Logger.info("Match ending soon - #{div(new_time, 1000)} seconds left")
    end

    if new_time <= 0 do
      Logger.info("Time's up - ending match now")
      send(self(), :finish)
      {:noreply, %{state | time_remaining: 0}}
    else
      schedule_timer()
      {:noreply, %{state | time_remaining: new_time}}
    end
  end

  def handle_info(:timer_tick, state) do
    Logger.info("Timer tick received but time already at 0 - ending match")
    send(self(), :finish)
    {:noreply, state}
  end

  def handle_info(:finish, state) do
    Logger.info("Match finishing between #{state.player_one.id} and #{state.player_two.id}")

    words_completed = calculate_words_completed(state)
    winner = determine_winner(words_completed, state.player_one, state.player_two)

    Logger.info(
      "Match winner: #{inspect(winner)} with words_completed: #{inspect(words_completed)}"
    )

    unregister_player(state.player_one.id)
    unregister_player(state.player_two.id)

    match_result = %{
      player_one: state.player_one,
      player_two: state.player_two,
      words_completed: words_completed,
      winner: winner,
      reason: "time_up"
    }

    Logger.info("Broadcasting match_finished: #{inspect(match_result)}")

    GameWeb.Endpoint.broadcast(@topic, "match_finished", match_result)
    broadcast_to_player(state.player_one.id, "match_finished", match_result)
    broadcast_to_player(state.player_two.id, "match_finished", match_result)

    MatchSupervisor.delete_match(state.player_one.id, state.player_two.id)
    {:stop, :normal, state}
  end

  def handle_info(%{event: "player_joined", payload: %{player_id: player_id}}, state) do
    Logger.info("Player joined event: #{player_id}")

    if player_id == state.player_one.id || player_id == state.player_two.id do
      Logger.info(
        "Player #{player_id} rejoined - re-broadcasting match data with #{length(state.words)} words"
      )

      broadcast_to_player(player_id, "match_started", %{
        player_one: state.player_one,
        player_two: state.player_two,
        words: state.words
      })
    end

    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.info("Match terminating with reason: #{inspect(reason)}")

    if Map.has_key?(state, :player_one) && state.player_one != nil do
      unregister_player(state.player_one.id)
    end

    if Map.has_key?(state, :player_two) && state.player_two != nil do
      unregister_player(state.player_two.id)
    end

    :ok
  end

  defp via_tuple(player_one, player_two) do
    Game.HordeRegistry.via_tuple({:match, player_one, player_two})
  end

  defp get_player(state, player_id) do
    cond do
      state.player_one.id == player_id -> {:player_one, state.player_one}
      state.player_two.id == player_id -> {:player_two, state.player_two}
      true -> {:error, :player_not_found}
    end
  end

  defp schedule_timer do
    Process.send_after(self(), :timer_tick, @timer_interval)
  end

  defp player_in_match?(player_id) do
    case HordeRegistry.lookup_player(player_id) do
      {:ok, _pid} -> true
      _ -> false
    end
  end

  defp unregister_player(player_id) do
    HordeRegistry.unregister_player(player_id)
  end

  defp calculate_words_completed(state) do
    %{
      state.player_one.id => state.player_one.words,
      state.player_two.id => state.player_two.words
    }
  end

  defp determine_winner(words_completed, player_one, player_two) do
    player_one_score = length(Map.get(words_completed, player_one.id, []))
    player_two_score = length(Map.get(words_completed, player_two.id, []))

    cond do
      player_one_score > player_two_score -> player_one
      player_two_score > player_one_score -> player_two
      true -> :draw
    end
  end

  defp broadcast_match_started(player_one, player_two, words) do
    GameWeb.Endpoint.broadcast(@topic, "match_started", %{
      player_one: player_one,
      player_two: player_two,
      words: words
    })

    broadcast_to_player(player_one.id, "match_started", %{
      player_one: player_one,
      player_two: player_two,
      words: words
    })

    broadcast_to_player(player_two.id, "match_started", %{
      player_one: player_one,
      player_two: player_two,
      words: words
    })
  end

  defp broadcast_to_player(player_id, event, payload) do
    GameWeb.Endpoint.broadcast("player:#{player_id}", event, payload)
  end
end
