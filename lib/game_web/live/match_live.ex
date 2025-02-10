defmodule GameWeb.MatchLive do
  use GameWeb, :live_view

  @topic "game:match"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      GameWeb.Endpoint.subscribe(@topic)
    end

    {:ok, assign(socket, :match_data, %{})}
  end

  def handle_info(
        %{
          event: "match_finished",
          payload: %{player_one: player_one, player_two: player_two, result: result}
        },
        socket
      ) do
    {:noreply,
     assign(socket, :match_data, %{player_one: player_one, player_two: player_two, result: result})
     |> redirect(to: ~p"/")}
  end
end
