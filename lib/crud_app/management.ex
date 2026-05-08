defmodule CrudApp.Management do
  @moduledoc """
  The Management context.
  """

  import Ecto.Query, warn: false
  alias CrudApp.Repo

  alias CrudApp.Management.Task

  alias CrudApp.Accounts.Scope

  @doc """
  Returns the list of tasks.
  """
  def list_tasks(%Scope{} = scope) do
    Repo.all_by(Task, assigned_to: scope.user.id)
  end

  def list_tasks do
    Repo.all(Task)
  end

  @doc """
  Gets a single task.
  """
  def get_task!(%Scope{} = scope, id) do
    Repo.get_by!(Task, [id: id, assigned_to: scope.user.id])
  end

  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.
  """
  def create_task(%Scope{} = scope, attrs) do
    %Task{}
    |> Task.changeset(attrs)
    |> Ecto.Changeset.put_change(:assigned_to, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
    |> Repo.insert()
  end

  def create_task(attrs) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.
  """
  def update_task(%Scope{} = scope, %Task{} = task, attrs) do
    true = task.assigned_to == scope.user.id
    task
    |> Task.changeset(attrs)
    |> Ecto.Changeset.put_change(:assigned_to, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
    |> Repo.update()
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.
  """
  def delete_task(%Scope{} = scope, %Task{} = task) do
    true = task.assigned_to == scope.user.id
    Repo.delete(task)
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.
  """
  def change_task(scope_or_task, task_or_attrs, attrs \\ %{})

  def change_task(%Scope{} = scope, %Task{} = task, attrs) do
    if task.assigned_to do
      true = task.assigned_to == scope.user.id
    end

    task
    |> Task.changeset(attrs)
    |> Ecto.Changeset.put_change(:assigned_to, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
  end

  def change_task(%Task{} = task, attrs, _unused) do
    Task.changeset(task, attrs)
  end
end
