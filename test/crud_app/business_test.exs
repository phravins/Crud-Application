defmodule CrudApp.BusinessTest do
  use CrudApp.DataCase

  alias CrudApp.Business

  describe "records" do
    alias CrudApp.Business.Record

    import CrudApp.AccountsFixtures, only: [user_scope_fixture: 0]
    import CrudApp.BusinessFixtures

    @invalid_attrs %{name: nil, metadata: nil, category: nil}

    test "list_records/1 returns all scoped records" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      record = record_fixture(scope)
      other_record = record_fixture(other_scope)
      assert Business.list_records(scope) == [record]
      assert Business.list_records(other_scope) == [other_record]
    end

    test "get_record!/2 returns the record with given id" do
      scope = user_scope_fixture()
      record = record_fixture(scope)
      other_scope = user_scope_fixture()
      assert Business.get_record!(scope, record.id) == record
      assert_raise Ecto.NoResultsError, fn -> Business.get_record!(other_scope, record.id) end
    end

    test "create_record/2 with valid data creates a record" do
      valid_attrs = %{name: "some name", metadata: %{}, category: "some category"}
      scope = user_scope_fixture()

      assert {:ok, %Record{} = record} = Business.create_record(scope, valid_attrs)
      assert record.name == "some name"
      assert record.metadata == %{}
      assert record.category == "some category"
      assert record.user_id == scope.user.id
    end

    test "create_record/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Business.create_record(scope, @invalid_attrs)
    end

    test "update_record/3 with valid data updates the record" do
      scope = user_scope_fixture()
      record = record_fixture(scope)
      update_attrs = %{name: "some updated name", metadata: %{}, category: "some updated category"}

      assert {:ok, %Record{} = record} = Business.update_record(scope, record, update_attrs)
      assert record.name == "some updated name"
      assert record.metadata == %{}
      assert record.category == "some updated category"
    end

    test "update_record/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      record = record_fixture(scope)

      assert_raise MatchError, fn ->
        Business.update_record(other_scope, record, %{})
      end
    end

    test "update_record/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      record = record_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Business.update_record(scope, record, @invalid_attrs)
      assert record == Business.get_record!(scope, record.id)
    end

    test "delete_record/2 deletes the record" do
      scope = user_scope_fixture()
      record = record_fixture(scope)
      assert {:ok, %Record{}} = Business.delete_record(scope, record)
      assert_raise Ecto.NoResultsError, fn -> Business.get_record!(scope, record.id) end
    end

    test "delete_record/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      record = record_fixture(scope)
      assert_raise MatchError, fn -> Business.delete_record(other_scope, record) end
    end

    test "change_record/2 returns a record changeset" do
      scope = user_scope_fixture()
      record = record_fixture(scope)
      assert %Ecto.Changeset{} = Business.change_record(scope, record)
    end
  end
end
