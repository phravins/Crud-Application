defmodule CrudApp.Accounting do
  @moduledoc """
  The Accounting context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias CrudApp.Repo

  alias CrudApp.Accounting.Expense

  alias CrudApp.Accounts.Scope

  @doc """
  Returns the list of expenses.

  ## Examples

      iex> list_expenses(scope)
      [%Expense{}, ...]

  """
  def list_expenses(%Scope{} = scope) do
    Repo.all_by(Expense, user_id: scope.user.id)
  end

  def list_expenses, do: Repo.all(Expense)

  @doc """
  Gets a single expense.

  Raises `Ecto.NoResultsError` if the Expense does not exist.

  ## Examples

      iex> get_expense!(scope, 123)
      %Expense{}

  """
  def get_expense!(%Scope{} = scope, id) do
    Repo.get_by!(Expense, [id: id, user_id: scope.user.id])
  end

  def get_expense!(id), do: Repo.get!(Expense, id)

  @doc """
  Creates a expense.

  ## Examples

      iex> create_expense(scope, %{field: value})
      {:ok, %Expense{}}

  """
  def create_expense(%Scope{} = scope, attrs) do
    %Expense{}
    |> Expense.changeset(attrs)
    |> put_change(:user_id, scope.user.id)
    |> put_change(:user_email, scope.user.email)
    |> IO.inspect(label: "SAVING EXPENSE WITH EMAIL")
    |> Repo.insert()
  end

  def create_expense(attrs) do
    %Expense{}
    |> Expense.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a expense.
  """
  def update_expense(%Scope{} = scope, %Expense{} = expense, attrs) do
    true = expense.user_id == scope.user.id
    expense
    |> Expense.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
    |> Repo.update()
  end

  def update_expense(%Expense{} = expense, attrs) do
    expense
    |> Expense.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a expense.
  """
  def delete_expense(%Scope{} = scope, %Expense{} = expense) do
    true = expense.user_id == scope.user.id
    Repo.delete(expense)
  end

  def delete_expense(%Expense{} = expense) do
    Repo.delete(expense)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking expense changes.
  """
  def change_expense(scope_or_expense, expense_or_attrs, attrs \\ %{})

  def change_expense(%Scope{} = scope, %Expense{} = expense, attrs) do
    if expense.user_id do
      true = expense.user_id == scope.user.id
    end

    expense
    |> Expense.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
  end

  def change_expense(%Expense{} = expense, attrs, _unused) do
    Expense.changeset(expense, attrs)
  end

  alias CrudApp.Accounting.Income

  @doc """
  Returns the list of incomes.
  """
  def list_incomes(%Scope{} = scope) do
    Repo.all_by(Income, user_id: scope.user.id)
  end

  def list_incomes do
    Repo.all(Income)
  end

  @doc """
  Gets a single income.
  """
  def get_income!(%Scope{} = scope, id) do
    Repo.get_by!(Income, [id: id, user_id: scope.user.id])
  end

  def get_income!(id), do: Repo.get!(Income, id)

  @doc """
  Creates a income.
  """
  def create_income(%Scope{} = scope, attrs) do
    %Income{}
    |> Income.changeset(attrs)
    |> put_change(:user_id, scope.user.id)
    |> put_change(:user_email, scope.user.email)
    |> IO.inspect(label: "SAVING INCOME WITH EMAIL")
    |> Repo.insert()
  end

  def create_income(attrs) do
    %Income{}
    |> Income.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a income.
  """
  def update_income(%Scope{} = scope, %Income{} = income, attrs) do
    true = income.user_id == scope.user.id
    income
    |> Income.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
    |> Repo.update()
  end

  def update_income(%Income{} = income, attrs) do
    income
    |> Income.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a income.
  """
  def delete_income(%Scope{} = scope, %Income{} = income) do
    true = income.user_id == scope.user.id
    Repo.delete(income)
  end

  def delete_income(%Income{} = income) do
    Repo.delete(income)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking income changes.
  """
  def change_income(scope_or_income, income_or_attrs, attrs \\ %{})

  def change_income(%Scope{} = scope, %Income{} = income, attrs) do
    if income.user_id do
      true = income.user_id == scope.user.id
    end

    income
    |> Income.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, scope.user.id)
    |> Ecto.Changeset.put_change(:user_email, scope.user.email)
  end

  def change_income(%Income{} = income, attrs, _unused) do
    Income.changeset(income, attrs)
  end
end
