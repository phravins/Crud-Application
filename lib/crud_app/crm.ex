defmodule CrudApp.CRM do
  @moduledoc """
  The CRM context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias CrudApp.Repo

  alias CrudApp.CRM.Client

  alias CrudApp.Accounts.Scope

  @doc """
  Returns the list of clients.
  """
  def list_clients(%Scope{} = scope) do
    Repo.all_by(Client, user_id: scope.user.id)
  end

  def list_clients do
    Repo.all(Client)
  end

  @doc """
  Gets a single client.
  """
  def get_client!(%Scope{} = scope, id) do
    Repo.get_by!(Client, [id: id, user_id: scope.user.id])
  end

  def get_client!(id), do: Repo.get!(Client, id)

  @doc """
  Creates a client.
  """
  def create_client(%Scope{} = scope, attrs) do
    %Client{}
    |> Client.changeset(attrs)
    |> put_change(:user_id, scope.user.id)
    |> put_change(:user_email, scope.user.email)
    |> IO.inspect(label: "SAVING CLIENT WITH EMAIL")
    |> Repo.insert()
  end

  def create_client(attrs) do
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a client.
  """
  def update_client(%Scope{} = scope, %Client{} = client, attrs) do
    true = client.user_id == scope.user.id
    client
    |> Client.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
    |> Repo.update()
  end

  def update_client(%Client{} = client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a client.
  """
  def delete_client(%Scope{} = scope, %Client{} = client) do
    true = client.user_id == scope.user.id
    Repo.delete(client)
  end

  def delete_client(%Client{} = client) do
    Repo.delete(client)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking client changes.
  """
  def change_client(scope_or_client, client_or_attrs, attrs \\ %{})

  def change_client(%Scope{} = scope, %Client{} = client, attrs) do
    if client.user_id do
      true = client.user_id == scope.user.id
    end

    client
    |> Client.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
  end

  def change_client(%Client{} = client, attrs, _unused) do
    Client.changeset(client, attrs)
  end
end
