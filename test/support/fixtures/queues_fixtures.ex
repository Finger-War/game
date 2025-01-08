defmodule Game.QueuesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Game.Queues` context.
  """

  @doc """
  Generate a queue.
  """
  def queue_fixture(attrs \\ %{}) do
    {:ok, queue} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Game.Queues.create_queue()

    queue
  end
end
