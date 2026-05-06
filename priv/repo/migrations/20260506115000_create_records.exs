defmodule CrudApp.Repo.Migrations.CreateRecords do
  use Ecto.Migration

  def change do
    create table(:records) do
      add :name, :string
      add :category, :string
      add :metadata, :map
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:records, [:user_id])
  end
end
