defmodule CrudApp.Repo.Migrations.AddSignInCountToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :sign_in_count, :integer, default: 0
    end
  end
end
