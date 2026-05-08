defmodule CrudApp.Operations.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :status, :string
    field :due_date, :date
    field :assigned_to, :id
    field :user_email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :status, :due_date])
    |> validate_required([:title, :status, :due_date])
  end
end
