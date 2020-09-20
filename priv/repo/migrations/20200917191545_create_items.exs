defmodule Inventory.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :entry_date, :date, default: fragment("now()::date")
      add :expiry_date, :date

      timestamps()
    end

  end
end
