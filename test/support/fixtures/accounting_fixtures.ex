defmodule CrudApp.AccountingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CrudApp.Accounting` context.
  """

  @doc """
  Generate a expense.
  """
  def expense_fixture(attrs \\ %{}) do
    {:ok, expense} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        category: "some category",
        date: ~D[2026-05-06],
        title: "some title"
      })
      |> CrudApp.Accounting.create_expense()

    expense
  end

  @doc """
  Generate a income.
  """
  def income_fixture(attrs \\ %{}) do
    {:ok, income} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        date: ~D[2026-05-06],
        source: "some source",
        title: "some title"
      })
      |> CrudApp.Accounting.create_income()

    income
  end
end
