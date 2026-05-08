defmodule CrudAppWeb.ExpenseLiveTest do
  use CrudAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import CrudApp.AccountingFixtures

  @create_attrs %{date: "2026-05-06", title: "some title", category: "some category", amount: "120.5"}
  @update_attrs %{date: "2026-05-07", title: "some updated title", category: "some updated category", amount: "456.7"}
  @invalid_attrs %{date: nil, title: nil, category: nil, amount: nil}
  defp create_expense(_) do
    expense = expense_fixture()

    %{expense: expense}
  end

  describe "Index" do
    setup [:create_expense]

    test "lists all expenses", %{conn: conn, expense: expense} do
      {:ok, _index_live, html} = live(conn, ~p"/expenses")

      assert html =~ "Listing Expenses"
      assert html =~ expense.title
    end

    test "saves new expense", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/expenses")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Expense")
               |> render_click()
               |> follow_redirect(conn, ~p"/expenses/new")

      assert render(form_live) =~ "New Expense"

      assert form_live
             |> form("#expense-form", expense: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#expense-form", expense: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/expenses")

      html = render(index_live)
      assert html =~ "Expense created successfully"
      assert html =~ "some title"
    end

    test "updates expense in listing", %{conn: conn, expense: expense} do
      {:ok, index_live, _html} = live(conn, ~p"/expenses")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#expenses-#{expense.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/expenses/#{expense}/edit")

      assert render(form_live) =~ "Edit Expense"

      assert form_live
             |> form("#expense-form", expense: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#expense-form", expense: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/expenses")

      html = render(index_live)
      assert html =~ "Expense updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes expense in listing", %{conn: conn, expense: expense} do
      {:ok, index_live, _html} = live(conn, ~p"/expenses")

      assert index_live |> element("#expenses-#{expense.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#expenses-#{expense.id}")
    end
  end

  describe "Show" do
    setup [:create_expense]

    test "displays expense", %{conn: conn, expense: expense} do
      {:ok, _show_live, html} = live(conn, ~p"/expenses/#{expense}")

      assert html =~ "Show Expense"
      assert html =~ expense.title
    end

    test "updates expense and returns to show", %{conn: conn, expense: expense} do
      {:ok, show_live, _html} = live(conn, ~p"/expenses/#{expense}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/expenses/#{expense}/edit?return_to=show")

      assert render(form_live) =~ "Edit Expense"

      assert form_live
             |> form("#expense-form", expense: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#expense-form", expense: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/expenses/#{expense}")

      html = render(show_live)
      assert html =~ "Expense updated successfully"
      assert html =~ "some updated title"
    end
  end
end
