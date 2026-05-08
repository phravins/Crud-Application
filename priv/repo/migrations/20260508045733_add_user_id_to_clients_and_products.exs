defmodule CrudApp.Repo.Migrations.AddUserIdToClientsAndProducts do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      add :user_id, references(:users, on_delete: :nothing)
    end

    alter table(:products) do
      add :user_id, references(:users, on_delete: :nothing)
    end

    alter table(:tasks) do
      add :description, :text
    end

    create index(:clients, [:user_id])
    create index(:products, [:user_id])
  end
end
