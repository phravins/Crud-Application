defmodule CrudApp.Accounting.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :title, :string
    field :amount, :decimal
    field :category, :string
    field :date, :date
    field :user_id, :id
    field :user_email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:title, :amount, :category, :date])
    |> validate_required([:title, :amount, :category, :date])
  end
end
