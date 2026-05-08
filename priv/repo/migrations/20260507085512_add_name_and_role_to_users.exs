defmodule CrudApp.Repo.Migrations.AddNameAndRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :role, :string, default: "Staff"
    end
  end
end
