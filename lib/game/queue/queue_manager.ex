defmodule Game.Queue.QueueManager do
  @moduledoc """
    This module is responsible for queue manager.
  """

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: {:global, __MODULE__})
  end

  def init(state) do
    {:ok, state}
  end

  def add_to_queue(player_id) do
    GenServer.call({:global, __MODULE__}, {:add_to_queue, player_id})
  end

  def remove_from_queue(player_id) do
    GenServer.call({:global, __MODULE__}, {:remove_from_queue, player_id})
  end

  def list_queue do
    GenServer.call({:global, __MODULE__}, :list_queue)
  end

  def handle_call({:add_to_queue, player_id}, _from, state) do
    state = state ++ [player_id]

    {:reply, :ok, state}
  end

  def handle_call({:remove_from_queue, player_id}, _from, state) do
    state = List.delete(state, player_id)

    {:reply, :ok, state}
  end

  def handle_call(:list_queue, _from, state) do
    {:reply, state, state}
  end
end
