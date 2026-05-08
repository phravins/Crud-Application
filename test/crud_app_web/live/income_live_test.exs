defmodule CrudAppWeb.IncomeLiveTest do
  use CrudAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import CrudApp.AccountingFixtures

  @create_attrs %{date: "2026-05-06", title: "some title", source: "some source", amount: "120.5"}
  @update_attrs %{date: "2026-05-07", title: "some updated title", source: "some updated source", amount: "456.7"}
  @invalid_attrs %{date: nil, title: nil, source: nil, amount: nil}
  defp create_income(_) do
    income = income_fixture()

    %{income: income}
  end

  describe "Index" do
    setup [:create_income]

    test "lists all incomes", %{conn: conn, income: income} do
      {:ok, _index_live, html} = live(conn, ~p"/incomes")

      assert html =~ "Listing Incomes"
      assert html =~ income.title
    end

    test "saves new income", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/incomes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Income")
               |> render_click()
               |> follow_redirect(conn, ~p"/incomes/new")

      assert render(form_live) =~ "New Income"

      assert form_live
             |> form("#income-form", income: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#income-form", income: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/incomes")

      html = render(index_live)
      assert html =~ "Income created successfully"
      assert html =~ "some title"
    end

    test "updates income in listing", %{conn: conn, income: income} do
      {:ok, index_live, _html} = live(conn, ~p"/incomes")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#incomes-#{income.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/incomes/#{income}/edit")

      assert render(form_live) =~ "Edit Income"

      assert form_live
             |> form("#income-form", income: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#income-form", income: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/incomes")

      html = render(index_live)
      assert html =~ "Income updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes income in listing", %{conn: conn, income: income} do
      {:ok, index_live, _html} = live(conn, ~p"/incomes")

      assert index_live |> element("#incomes-#{income.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#incomes-#{income.id}")
    end
  end

  describe "Show" do
    setup [:create_income]

    test "displays income", %{conn: conn, income: income} do
      {:ok, _show_live, html} = live(conn, ~p"/incomes/#{income}")

      assert html =~ "Show Income"
      assert html =~ income.title
    end

    test "updates income and returns to show", %{conn: conn, income: income} do
      {:ok, show_live, _html} = live(conn, ~p"/incomes/#{income}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/incomes/#{income}/edit?return_to=show")

      assert render(form_live) =~ "Edit Income"

      assert form_live
             |> form("#income-form", income: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#income-form", income: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/incomes/#{income}")

      html = render(show_live)
      assert html =~ "Income updated successfully"
      assert html =~ "some updated title"
    end
  end
end
