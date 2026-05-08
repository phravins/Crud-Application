defmodule CrudApp.Repo.Migrations.CreateExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :title, :string
      add :amount, :decimal
      add :category, :string
      add :date, :date
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:expenses, [:user_id])
  end
end
