defmodule CrudApp.OperationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CrudApp.Operations` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        due_date: ~D[2026-05-06],
        status: "some status",
        title: "some title"
      })
      |> CrudApp.Operations.create_task()

    task
  end
end
