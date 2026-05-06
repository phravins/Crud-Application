defmodule CrudApp.ManagementFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CrudApp.Management` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        status: "some status",
        title: "some title"
      })
      |> CrudApp.Management.create_task()

    task
  end
end
