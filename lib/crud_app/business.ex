defmodule CrudApp.Business do
  @moduledoc """
  The Business context.
  """

  import Ecto.Query, warn: false
  alias CrudApp.Repo

  alias CrudApp.Business.Record
  alias CrudApp.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any record changes.

  The broadcasted messages match the pattern:

    * {:created, %Record{}}
    * {:updated, %Record{}}
    * {:deleted, %Record{}}

  """
  def subscribe_records(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(CrudApp.PubSub, "user:#{key}:records")
  end

  defp broadcast_record(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(CrudApp.PubSub, "user:#{key}:records", message)
  end

  @doc """
  Returns the list of records.

  ## Examples

      iex> list_records(scope)
      [%Record{}, ...]

  """
  def list_records(%Scope{} = scope) do
    Repo.all_by(Record, user_id: scope.user.id)
  end

  @doc """
  Gets a single record.

  Raises `Ecto.NoResultsError` if the Record does not exist.

  ## Examples

      iex> get_record!(scope, 123)
      %Record{}

      iex> get_record!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_record!(%Scope{} = scope, id) do
    Repo.get_by!(Record, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a record.

  ## Examples

      iex> create_record(scope, %{field: value})
      {:ok, %Record{}}

      iex> create_record(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_record(%Scope{} = scope, attrs) do
    with {:ok, record = %Record{}} <-
           %Record{}
           |> Record.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_record(scope, {:created, record})
      {:ok, record}
    end
  end

  @doc """
  Updates a record.

  ## Examples

      iex> update_record(scope, record, %{field: new_value})
      {:ok, %Record{}}

      iex> update_record(scope, record, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_record(%Scope{} = scope, %Record{} = record, attrs) do
    true = record.user_id == scope.user.id

    with {:ok, record = %Record{}} <-
           record
           |> Record.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_record(scope, {:updated, record})
      {:ok, record}
    end
  end

  @doc """
  Deletes a record.

  ## Examples

      iex> delete_record(scope, record)
      {:ok, %Record{}}

      iex> delete_record(scope, record)
      {:error, %Ecto.Changeset{}}

  """
  def delete_record(%Scope{} = scope, %Record{} = record) do
    true = record.user_id == scope.user.id

    with {:ok, record = %Record{}} <-
           Repo.delete(record) do
      broadcast_record(scope, {:deleted, record})
      {:ok, record}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking record changes.

  ## Examples

      iex> change_record(scope, record)
      %Ecto.Changeset{data: %Record{}}

  """
  def change_record(%Scope{} = scope, %Record{} = record, attrs \\ %{}) do
    true = record.user_id == scope.user.id

    Record.changeset(record, attrs, scope)
  end
end
