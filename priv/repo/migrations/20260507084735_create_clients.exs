defmodule CrudApp.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :address, :text

      timestamps(type: :utc_datetime)
    end
  end
end
