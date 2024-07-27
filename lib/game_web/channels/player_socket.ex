defmodule GameWeb.PlayerSocket do
  use Phoenix.Socket

  channel "queue:lobby", GameWeb.QueueChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
