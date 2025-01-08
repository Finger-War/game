defmodule GameWeb.MatchLive do
  use GameWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      GameWeb.Endpoint.subscribe("game:match")
    end

    {:ok, assign(socket, :match_data, %{})}
  end
end
