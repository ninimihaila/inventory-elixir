defmodule Inventory.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :entry_date, :date
    field :expiry_date, :date
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :entry_date, :expiry_date])
    |> validate_required([:name, :entry_date, :expiry_date])
  end
end
