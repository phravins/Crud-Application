defmodule CrudApp.Repo.Migrations.CreateIncomes do
  use Ecto.Migration

  def change do
    create table(:incomes) do
      add :title, :string
      add :amount, :decimal
      add :source, :string
      add :date, :date
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:incomes, [:user_id])
  end
end
