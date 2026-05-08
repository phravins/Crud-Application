defmodule CrudApp.Repo.Migrations.CreateTasksV2 do
  use Ecto.Migration

  def change do
    drop_if_exists table(:tasks)

    create table(:tasks) do
      add :title, :string
      add :status, :string
      add :due_date, :date
      add :assigned_to, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:assigned_to])
  end
end
