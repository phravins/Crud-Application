defmodule CrudApp.Business.Record do
  use Ecto.Schema
  import Ecto.Changeset

  schema "records" do
    field :name, :string
    field :category, :string
    field :metadata, :map
    field :user_id, :id
    field :user_email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :category, :metadata])
    |> validate_required([:name, :category])
  end
end
