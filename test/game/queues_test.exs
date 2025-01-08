defmodule Game.QueuesTest do
  use Game.DataCase

  alias Game.Queues

  describe "queues" do
    alias Game.Queues.Queue

    import Game.QueuesFixtures

    @invalid_attrs %{name: nil}

    test "list_queues/0 returns all queues" do
      queue = queue_fixture()
      assert Queues.list_queues() == [queue]
    end

    test "get_queue!/1 returns the queue with given id" do
      queue = queue_fixture()
      assert Queues.get_queue!(queue.id) == queue
    end

    test "create_queue/1 with valid data creates a queue" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Queue{} = queue} = Queues.create_queue(valid_attrs)
      assert queue.name == "some name"
    end

    test "create_queue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Queues.create_queue(@invalid_attrs)
    end

    test "update_queue/2 with valid data updates the queue" do
      queue = queue_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Queue{} = queue} = Queues.update_queue(queue, update_attrs)
      assert queue.name == "some updated name"
    end

    test "update_queue/2 with invalid data returns error changeset" do
      queue = queue_fixture()
      assert {:error, %Ecto.Changeset{}} = Queues.update_queue(queue, @invalid_attrs)
      assert queue == Queues.get_queue!(queue.id)
    end

    test "delete_queue/1 deletes the queue" do
      queue = queue_fixture()
      assert {:ok, %Queue{}} = Queues.delete_queue(queue)
      assert_raise Ecto.NoResultsError, fn -> Queues.get_queue!(queue.id) end
    end

    test "change_queue/1 returns a queue changeset" do
      queue = queue_fixture()
      assert %Ecto.Changeset{} = Queues.change_queue(queue)
    end
  end
end
