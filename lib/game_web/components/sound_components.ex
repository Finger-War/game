defmodule GameWeb.SoundComponents do
  use Phoenix.Component

  attr(:sounds, :list, default: [])

  def preload_sounds(assigns) do
    default_sounds = [
      %{id: "start_match", path: "/sounds/start_match.wav"},
      %{id: "correct", path: "/sounds/correct.wav"},
      %{id: "incorrect", path: "/sounds/incorrect.wav"},
      %{id: "countdown", path: "/sounds/countdown.wav"},
      %{id: "victory", path: "/sounds/victory.wav"},
      %{id: "defeat", path: "/sounds/defeat.wav"},
      %{id: "typing", path: "/sounds/typing.mp3"}
    ]

    sounds = assigns[:sounds] || default_sounds

    ~H"""
    <div class="hidden" aria-hidden="true">
      <%= for sound <- sounds do %>
        <audio id={"sound-#{sound.id}"} src={sound.path} preload="auto"></audio>
      <% end %>
    </div>
    """
  end
end
