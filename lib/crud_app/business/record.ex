defmodule CrudApp.Business.Record do
  use Ecto.Schema
  import Ecto.Changeset

  schema "records" do
    field :name, :string
    field :category, :string
    field :metadata, :map
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(record, attrs, user_scope) do
    record
    |> cast(attrs, [:name, :category, :metadata])
    |> validate_required([:name, :category])
    |> put_change(:user_id, user_scope.user.id)
  end
end
