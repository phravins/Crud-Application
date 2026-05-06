defmodule CrudApp.ManagementTest do
  use CrudApp.DataCase

  alias CrudApp.Management

  describe "tasks" do
    alias CrudApp.Management.Task

    import CrudApp.ManagementFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Management.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Management.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{status: "some status", description: "some description", title: "some title"}

      assert {:ok, %Task{} = task} = Management.create_task(valid_attrs)
      assert task.status == "some status"
      assert task.description == "some description"
      assert task.title == "some title"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Management.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      update_attrs = %{status: "some updated status", description: "some updated description", title: "some updated title"}

      assert {:ok, %Task{} = task} = Management.update_task(task, update_attrs)
      assert task.status == "some updated status"
      assert task.description == "some updated description"
      assert task.title == "some updated title"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Management.update_task(task, @invalid_attrs)
      assert task == Management.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Management.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Management.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Management.change_task(task)
    end
  end
end
