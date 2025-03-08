defmodule GameWeb.MatchComponents do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr(:match_status, :atom, required: true)

  def game_header(assigns) do
    ~H"""
    <div class="game-header p-3 bg-black bg-opacity-30 flex justify-between items-center">
      <div class="flex items-center">
        <div class="text-yellow-400 font-bold text-xl mr-2">
          <i class="fas fa-keyboard"></i> FINGERWAR
        </div>

        <div class={[
          "game-status px-2 py-1 rounded text-xs uppercase font-bold",
          @match_status == :playing && "bg-green-500" || "bg-gray-500"
        ]}>
          <%= @match_status %>
        </div>
      </div>

      <.game_timer time_remaining={@time_remaining} />
    </div>
    """
  end

  attr(:time_remaining, :integer, required: true)

  def game_timer(assigns) do
    ~H"""
    <div class="game-timer-wrapper flex items-center">
      <div class="timer-label mr-2 font-bold">TIME:</div>
      <div class="timer-display flex items-center">
        <div class={[
          "countdown-number",
          @time_remaining <= 10 && "text-red-500 animate-pulse" || "text-white"
        ]}>
          <%= @time_remaining %>
        </div>
      </div>
    </div>
    """
  end

  attr(:player, :map, required: true)
  attr(:title, :string, required: true)
  attr(:bg_color, :string, required: true)
  attr(:text_color, :string, required: true)

  def player_header(assigns) do
    ~H"""
    <div class={"player-header p-3 #{@bg_color} flex items-center justify-between"}>
      <div class="player-info flex items-center">
        <div class={"player-avatar #{@bg_color} h-10 w-10 rounded-full flex items-center justify-center text-xl"}>
          <i class="fas fa-user"></i>
        </div>
        <div class="ml-2">
          <div class="font-bold"><%= @title %></div>
          <div class={"text-xs #{@text_color}"}>
            <%= if is_map(@player) do %>
              <%= @player.id %>
            <% else %>
              <%= @player %>
            <% end %>
          </div>
        </div>
      </div>
      <div class="player-score">
        <div class={"text-xs font-bold #{@text_color}"}>SCORE</div>
        <div class="text-2xl font-bold text-white">
          <%= if is_map(@player) do %>
            <%= @player.score || 0 %>
          <% else %>
            0
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr(:words, :list, required: true)
  attr(:word_statuses, :map, required: true)
  attr(:current_target_word, :string, default: nil)
  attr(:color_class, :string, required: true)
  attr(:header_color, :string, required: true)

  def word_container(assigns) do
    ~H"""
    <div class="game-area p-4 flex-grow flex flex-col">
      <div class="words-container mb-4 flex-grow overflow-y-auto">
        <h3 class={"text-lg mb-2 font-bold #{@header_color}"}>Available Words:</h3>
        <div class="flex flex-wrap gap-2">
          <%= for word <- @words do %>
            <div class={[
              "word-item px-3 py-1.5 rounded-lg transition",
              cond do
                @current_target_word == word -> "bg-blue-600 border-2 border-white font-bold animate-pulse"
                Map.get(@word_statuses, word) == :correct -> "bg-green-600"
                Map.get(@word_statuses, word) == :incorrect -> "bg-red-600"
                true -> @color_class
              end
            ]}>
              <%= word %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr(:current_target_word, :string, default: nil)
  attr(:current_input, :string, default: "")
  attr(:match_status, :atom, required: true)
  attr(:current_player, :map, required: true)
  attr(:opponent, :map, required: true)

  def central_input(assigns) do
    ~H"""
    <div class="central-input-area absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-20 w-5/6 max-w-xl">
      <div class="versus-indicator absolute -top-12 left-1/2 transform -translate-x-1/2 z-10">
        <div class="bg-yellow-500 text-black rounded-full h-12 w-12 flex items-center justify-center font-bold text-2xl shadow-lg border-2 border-white">
          VS
        </div>
      </div>

      <div class="game-input-wrapper bg-black bg-opacity-50 p-4 rounded-xl border-2 border-indigo-500 shadow-lg">
        <h3 class="text-center text-white font-bold mb-3">
          <%= if @current_target_word do %>
            TYPE: <span class="text-yellow-300"><%= @current_target_word %></span>
          <% else %>
            TYPE THE WORDS ABOVE TO SCORE
          <% end %>
        </h3>

        <form phx-submit="type" phx-change="input_change" class="relative">
          <input
            type="text"
            id="word-input"
            name="word"
            value={@current_input}
            placeholder={if @match_status == :playing, do: "Type a word quickly!", else: "Waiting..."}
            class="w-full p-4 rounded-lg bg-blue-900 border-2 border-blue-600 text-white text-lg font-medium placeholder-blue-400 focus:border-blue-400 focus:ring-2 focus:ring-blue-500 focus:outline-none"
            disabled={@match_status != :playing}
            autofocus
            autocomplete="off"
            phx-hook="GameInput"
          />
          <div id="input-feedback" class="hidden absolute top-0 left-0 w-full h-full rounded-lg"></div>
        </form>

        <div class="flex justify-between mt-3 text-sm">
          <div class="flex items-center text-blue-300">
            <div class="w-3 h-3 rounded-full bg-blue-500 mr-2"></div>
            <div>Your Score:
              <span class="font-bold">
                <%= if is_map(@current_player), do: @current_player.score || 0, else: 0 %>
              </span>
            </div>
          </div>

          <div class="flex items-center text-red-300">
            <div>Opponent Score:
              <span class="font-bold">
                <%= if is_map(@opponent), do: @opponent.score || 0, else: 0 %>
              </span>
            </div>
            <div class="w-3 h-3 rounded-full bg-red-500 ml-2"></div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr(:match_status, :atom, required: true)
  attr(:time_remaining, :integer, required: true)

  def countdown_bar(assigns) do
    ~H"""
    <%= if @match_status == :playing do %>
      <div class="game-countdown-bar fixed bottom-0 left-0 right-0 h-4 bg-gray-800">
        <div class="countdown-progress h-full bg-gradient-to-r from-green-500 to-blue-500 transition-all duration-1000"
            style={"width: #{(@time_remaining / 60) * 100}%"}></div>
      </div>
    <% end %>
    """
  end

  attr(:match_status, :atom, required: true)

  def waiting_overlay(assigns) do
    ~H"""
    <%= if @match_status == :waiting do %>
      <div class="waiting-overlay fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center z-40">
        <div class="text-center">
          <div class="loading-spinner mb-4">
            <div class="animate-spin rounded-full h-16 w-16 border-4 border-blue-500 border-t-transparent"></div>
          </div>
          <h2 class="text-2xl font-bold mb-2">Preparing Match</h2>
          <p class="text-blue-300">Getting everything ready...</p>
        </div>
      </div>
    <% end %>
    """
  end

  attr(:match_status, :atom, required: true)
  attr(:is_winner, :boolean, required: true)
  attr(:is_draw, :boolean, required: true)
  attr(:winner_message, :string, default: "")
  attr(:your_score, :integer, required: true)
  attr(:opponent_score, :integer, required: true)

  def match_result(assigns) do
    assigns = assign_new(assigns, :winner_message, fn -> "" end)

    ~H"""
    <%= if @match_status == :finished do %>
      <div class="match-finished-overlay fixed inset-0 bg-black bg-opacity-80 flex items-center justify-center z-50">
        <div class={[
          "result-card bg-gray-900 p-8 rounded-xl shadow-2xl max-w-md w-full border-2",
          cond do
            @is_winner -> "border-green-500"
            @is_draw -> "border-yellow-500"
            true -> "border-red-500"
          end
        ]}>

          <%= cond do %>
            <% @is_draw -> %>
              <div class="result-header text-center mb-6">
                <div class="result-icon mb-3">
                  <i class="fas fa-balance-scale text-6xl text-yellow-400"></i>
                </div>
                <h2 class="text-2xl font-bold">IT'S A DRAW!</h2>
                <p class="text-yellow-300 mt-1"><%= @winner_message %></p>
              </div>

              <div class="stats-comparison p-4 bg-gray-800 rounded-lg flex justify-around mb-6">
                <div class="text-center">
                  <div class="text-3xl font-bold text-white mb-1"><%= @your_score %></div>
                  <div class="text-xs uppercase text-gray-400">Your Words</div>
                </div>
                <div class="text-center">
                  <div class="text-3xl font-bold text-white mb-1"><%= @opponent_score %></div>
                  <div class="text-xs uppercase text-gray-400">Opponent Words</div>
                </div>
              </div>

              <div class="text-center text-yellow-400 mb-6">
                So close! Next time someone will win!
              </div>

            <% @is_winner -> %>
              <div class="result-header text-center mb-6">
                <div class="result-icon animate-bounce mb-3">
                  <i class="fas fa-trophy text-6xl text-yellow-400"></i>
                </div>
                <h2 class="text-2xl font-bold text-green-400">VICTORY!</h2>
                <p class="text-green-300 mt-1"><%= @winner_message %></p>
              </div>

              <div class="stats-comparison p-4 bg-gray-800 rounded-lg flex justify-around mb-6">
                <div class="text-center">
                  <div class="text-3xl font-bold text-green-400 mb-1"><%= @your_score %></div>
                  <div class="text-xs uppercase text-gray-400">Your Words</div>
                </div>
                <div class="text-center">
                  <div class="text-3xl font-bold text-red-400 mb-1"><%= @opponent_score %></div>
                  <div class="text-xs uppercase text-gray-400">Opponent Words</div>
                </div>
              </div>

              <div class="achievement-badge text-center p-3 bg-yellow-900 bg-opacity-30 rounded-lg mb-6">
                <div class="text-yellow-400"><i class="fas fa-medal mr-1"></i> ACHIEVEMENT UNLOCKED</div>
                <div class="text-white font-bold">Speed Demon</div>
              </div>

            <% true -> %>
              <div class="result-header text-center mb-6">
                <div class="result-icon mb-3">
                  <i class="fas fa-thumbs-up text-5xl text-blue-400"></i>
                </div>
                <h2 class="text-2xl font-bold text-blue-400">GOOD EFFORT!</h2>
                <p class="text-blue-300 mt-1"><%= @winner_message %></p>
              </div>

              <div class="stats-comparison p-4 bg-gray-800 rounded-lg flex justify-around mb-6">
                <div class="text-center">
                  <div class="text-3xl font-bold text-white mb-1"><%= @your_score %></div>
                  <div class="text-xs uppercase text-gray-400">Your Words</div>
                </div>
                <div class="text-center">
                  <div class="text-3xl font-bold text-green-400 mb-1"><%= @opponent_score %></div>
                  <div class="text-xs uppercase text-gray-400">Opponent Words</div>
                </div>
              </div>

              <div class="text-center text-blue-400 mb-6">
                Don't worry! Practice makes perfect.
              </div>
          <% end %>

          <button phx-click="redirect" class="w-full py-3 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg flex items-center justify-center transition">
            <i class="fas fa-home mr-2"></i> Return to Main Menu
          </button>
        </div>
      </div>
    <% end %>
    """
  end

  def sound_effects(assigns) do
    ~H"""
    <div class="hidden">
      <audio id="sound-start_match" src="/sounds/start_match.wav" preload="auto"></audio>
      <audio id="sound-correct" src="/sounds/correct.wav" preload="auto"></audio>
      <audio id="sound-incorrect" src="/sounds/incorrect.wav" preload="auto"></audio>
      <audio id="sound-countdown" src="/sounds/countdown.wav" preload="auto"></audio>
      <audio id="sound-victory" src="/sounds/victory.wav" preload="auto"></audio>
      <audio id="sound-defeat" src="/sounds/defeat.wav" preload="auto"></audio>
      <audio id="sound-typing" src="/sounds/typing.mp3" preload="auto"></audio>
    </div>
    """
  end

  attr(:current_player, :any, required: true)
  attr(:opponent, :any, required: true)

  def advantage_indicators(assigns) do
    ~H"""
    <%= if @current_player && @opponent && @current_player.score > @opponent.score && @current_player.score > 0 do %>
      <div class="player-advantage absolute top-1/3 left-1/4 transform -translate-x-1/2 -translate-y-1/2">
        <div class="spark-effect animate-spark">
          <i class="fas fa-bolt text-yellow-400 text-4xl"></i>
        </div>
      </div>
    <% end %>

    <%= if @opponent && @current_player && @opponent.score > @current_player.score && @opponent.score > 0 do %>
      <div class="opponent-advantage absolute top-1/3 right-1/4 transform translate-x-1/2 -translate-y-1/2">
        <div class="spark-effect animate-spark">
          <i class="fas fa-bolt text-yellow-400 text-4xl"></i>
        </div>
      </div>
    <% end %>
    """
  end
end
