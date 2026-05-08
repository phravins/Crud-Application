defmodule CrudApp.Inventory.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :price, :decimal
    field :stock, :integer
    field :user_id, :id
    field :user_email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :price, :stock])
    |> validate_required([:name, :price, :stock])
  end
end
