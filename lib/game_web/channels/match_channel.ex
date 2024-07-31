defmodule GameWeb.MatchChannel do
  @moduledoc """
    This module is responsible for match channel.
  """

  use GameWeb, :channel

  @impl true
  def join("match:lobby", _payload, socket) do
    {:ok, socket}
  end
end
