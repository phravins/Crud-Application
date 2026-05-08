defmodule CrudApp.Accounting.Income do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incomes" do
    field :title, :string
    field :amount, :decimal
    field :source, :string
    field :date, :date
    field :user_id, :id
    field :user_email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(income, attrs) do
    income
    |> cast(attrs, [:title, :amount, :source, :date])
    |> validate_required([:title, :amount, :source, :date])
  end
end
