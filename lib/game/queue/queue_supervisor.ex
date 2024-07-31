defmodule Game.Queue.QueueSupervisor do
  @moduledoc """
    This module is responsible for queue supervisor.
  """

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Game.Queue.QueueManager,
      Game.Queue.Queue
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
