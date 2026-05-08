defmodule CrudApp.CRM.Client do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :address, :string
    field :user_id, :id
    field :user_email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:name, :email, :phone, :address])
    |> validate_required([:name, :email, :phone, :address])
  end
end
