defmodule CrudApp.AccountingTest do
  use CrudApp.DataCase

  alias CrudApp.Accounting

  describe "expenses" do
    alias CrudApp.Accounting.Expense

    import CrudApp.AccountingFixtures

    @invalid_attrs %{date: nil, title: nil, category: nil, amount: nil}

    test "list_expenses/0 returns all expenses" do
      expense = expense_fixture()
      assert Accounting.list_expenses() == [expense]
    end

    test "get_expense!/1 returns the expense with given id" do
      expense = expense_fixture()
      assert Accounting.get_expense!(expense.id) == expense
    end

    test "create_expense/1 with valid data creates a expense" do
      valid_attrs = %{date: ~D[2026-05-06], title: "some title", category: "some category", amount: "120.5"}

      assert {:ok, %Expense{} = expense} = Accounting.create_expense(valid_attrs)
      assert expense.date == ~D[2026-05-06]
      assert expense.title == "some title"
      assert expense.category == "some category"
      assert expense.amount == Decimal.new("120.5")
    end

    test "create_expense/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_expense(@invalid_attrs)
    end

    test "update_expense/2 with valid data updates the expense" do
      expense = expense_fixture()
      update_attrs = %{date: ~D[2026-05-07], title: "some updated title", category: "some updated category", amount: "456.7"}

      assert {:ok, %Expense{} = expense} = Accounting.update_expense(expense, update_attrs)
      assert expense.date == ~D[2026-05-07]
      assert expense.title == "some updated title"
      assert expense.category == "some updated category"
      assert expense.amount == Decimal.new("456.7")
    end

    test "update_expense/2 with invalid data returns error changeset" do
      expense = expense_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_expense(expense, @invalid_attrs)
      assert expense == Accounting.get_expense!(expense.id)
    end

    test "delete_expense/1 deletes the expense" do
      expense = expense_fixture()
      assert {:ok, %Expense{}} = Accounting.delete_expense(expense)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_expense!(expense.id) end
    end

    test "change_expense/1 returns a expense changeset" do
      expense = expense_fixture()
      assert %Ecto.Changeset{} = Accounting.change_expense(expense)
    end
  end

  describe "incomes" do
    alias CrudApp.Accounting.Income

    import CrudApp.AccountingFixtures

    @invalid_attrs %{date: nil, title: nil, source: nil, amount: nil}

    test "list_incomes/0 returns all incomes" do
      income = income_fixture()
      assert Accounting.list_incomes() == [income]
    end

    test "get_income!/1 returns the income with given id" do
      income = income_fixture()
      assert Accounting.get_income!(income.id) == income
    end

    test "create_income/1 with valid data creates a income" do
      valid_attrs = %{date: ~D[2026-05-06], title: "some title", source: "some source", amount: "120.5"}

      assert {:ok, %Income{} = income} = Accounting.create_income(valid_attrs)
      assert income.date == ~D[2026-05-06]
      assert income.title == "some title"
      assert income.source == "some source"
      assert income.amount == Decimal.new("120.5")
    end

    test "create_income/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_income(@invalid_attrs)
    end

    test "update_income/2 with valid data updates the income" do
      income = income_fixture()
      update_attrs = %{date: ~D[2026-05-07], title: "some updated title", source: "some updated source", amount: "456.7"}

      assert {:ok, %Income{} = income} = Accounting.update_income(income, update_attrs)
      assert income.date == ~D[2026-05-07]
      assert income.title == "some updated title"
      assert income.source == "some updated source"
      assert income.amount == Decimal.new("456.7")
    end

    test "update_income/2 with invalid data returns error changeset" do
      income = income_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_income(income, @invalid_attrs)
      assert income == Accounting.get_income!(income.id)
    end

    test "delete_income/1 deletes the income" do
      income = income_fixture()
      assert {:ok, %Income{}} = Accounting.delete_income(income)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_income!(income.id) end
    end

    test "change_income/1 returns a income changeset" do
      income = income_fixture()
      assert %Ecto.Changeset{} = Accounting.change_income(income)
    end
  end
end
