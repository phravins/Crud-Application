defmodule CrudApp.OperationsTest do
  use CrudApp.DataCase

  alias CrudApp.Operations

  describe "tasks" do
    alias CrudApp.Operations.Task

    import CrudApp.OperationsFixtures

    @invalid_attrs %{status: nil, title: nil, due_date: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Operations.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Operations.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{status: "some status", title: "some title", due_date: ~D[2026-05-06]}

      assert {:ok, %Task{} = task} = Operations.create_task(valid_attrs)
      assert task.status == "some status"
      assert task.title == "some title"
      assert task.due_date == ~D[2026-05-06]
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Operations.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      update_attrs = %{status: "some updated status", title: "some updated title", due_date: ~D[2026-05-07]}

      assert {:ok, %Task{} = task} = Operations.update_task(task, update_attrs)
      assert task.status == "some updated status"
      assert task.title == "some updated title"
      assert task.due_date == ~D[2026-05-07]
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Operations.update_task(task, @invalid_attrs)
      assert task == Operations.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Operations.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Operations.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Operations.change_task(task)
    end
  end
end
