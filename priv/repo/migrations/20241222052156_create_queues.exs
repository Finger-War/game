defmodule Game.Repo.Migrations.CreateQueues do
  use Ecto.Migration

  def change do
    create table(:queues) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
