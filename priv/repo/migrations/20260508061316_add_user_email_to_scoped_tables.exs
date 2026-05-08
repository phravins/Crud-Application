defmodule CrudApp.Repo.Migrations.AddUserEmailToScopedTables do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      add :user_email, :string
    end

    alter table(:expenses) do
      add :user_email, :string
    end

    alter table(:incomes) do
      add :user_email, :string
    end

    alter table(:tasks) do
      add :user_email, :string
    end

    alter table(:products) do
      add :user_email, :string
    end

    alter table(:records) do
      add :user_email, :string
    end

    create index(:clients, [:user_email])
    create index(:expenses, [:user_email])
    create index(:incomes, [:user_email])
    create index(:tasks, [:user_email])
    create index(:products, [:user_email])
    create index(:records, [:user_email])
  end
end
