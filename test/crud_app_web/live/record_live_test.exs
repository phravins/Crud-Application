defmodule CrudAppWeb.RecordLiveTest do
  use CrudAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import CrudApp.BusinessFixtures

  @create_attrs %{name: "some name", metadata: %{}, category: "some category"}
  @update_attrs %{name: "some updated name", metadata: %{}, category: "some updated category"}
  @invalid_attrs %{name: nil, metadata: nil, category: nil}

  setup :register_and_log_in_user

  defp create_record(%{scope: scope}) do
    record = record_fixture(scope)

    %{record: record}
  end

  describe "Index" do
    setup [:create_record]

    test "lists all records", %{conn: conn, record: record} do
      {:ok, _index_live, html} = live(conn, ~p"/records")

      assert html =~ "Listing Records"
      assert html =~ record.name
    end

    test "saves new record", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/records")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Record")
               |> render_click()
               |> follow_redirect(conn, ~p"/records/new")

      assert render(form_live) =~ "New Record"

      assert form_live
             |> form("#record-form", record: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#record-form", record: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/records")

      html = render(index_live)
      assert html =~ "Record created successfully"
      assert html =~ "some name"
    end

    test "updates record in listing", %{conn: conn, record: record} do
      {:ok, index_live, _html} = live(conn, ~p"/records")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#records-#{record.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/records/#{record}/edit")

      assert render(form_live) =~ "Edit Record"

      assert form_live
             |> form("#record-form", record: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#record-form", record: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/records")

      html = render(index_live)
      assert html =~ "Record updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes record in listing", %{conn: conn, record: record} do
      {:ok, index_live, _html} = live(conn, ~p"/records")

      assert index_live |> element("#records-#{record.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#records-#{record.id}")
    end
  end

  describe "Show" do
    setup [:create_record]

    test "displays record", %{conn: conn, record: record} do
      {:ok, _show_live, html} = live(conn, ~p"/records/#{record}")

      assert html =~ "Show Record"
      assert html =~ record.name
    end

    test "updates record and returns to show", %{conn: conn, record: record} do
      {:ok, show_live, _html} = live(conn, ~p"/records/#{record}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/records/#{record}/edit?return_to=show")

      assert render(form_live) =~ "Edit Record"

      assert form_live
             |> form("#record-form", record: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#record-form", record: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/records/#{record}")

      html = render(show_live)
      assert html =~ "Record updated successfully"
      assert html =~ "some updated name"
    end
  end
end
