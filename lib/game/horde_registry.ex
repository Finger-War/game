defmodule Game.HordeRegistry do
  @moduledoc """
  Distributed registry for processes across the cluster.
  """

  use Horde.Registry
  require Logger

  def start_link(_) do
    Horde.Registry.start_link(__MODULE__, keys: :unique, name: __MODULE__)
  end

  def init(init_arg) do
    [members: members()]
    |> Keyword.merge(init_arg)
    |> Horde.Registry.init()
  end

  def members() do
    [Node.self() | Node.list()]
    |> Enum.map(fn node -> {__MODULE__, node} end)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def register_player(player_id, pid) do
    Logger.info("Registering player #{player_id} in Horde Registry")
    Horde.Registry.register(__MODULE__, {:player, player_id}, pid)
  end

  def unregister_player(player_id) do
    Logger.info("Unregistering player #{player_id} from Horde Registry")
    Horde.Registry.unregister(__MODULE__, {:player, player_id})
  end

  def lookup_player(player_id) do
    case Horde.Registry.lookup(__MODULE__, {:player, player_id}) do
      [{pid, _}] -> {:ok, pid}
      [] -> :error
    end
  end

  def via_tuple(key) do
    {:via, Horde.Registry, {__MODULE__, key}}
  end
end
