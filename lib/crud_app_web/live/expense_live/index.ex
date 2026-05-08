defmodule CrudAppWeb.ExpenseLive.Index do
  use CrudAppWeb, :live_view

  alias CrudApp.Accounting

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Expenses
        <:actions>
          <.button variant="primary" navigate={~p"/expenses/new"}>
            <.icon name="hero-plus" /> New Expense
          </.button>
        </:actions>
      </.header>

      <.table
        id="expenses"
        rows={@streams.expenses}
        row_click={fn {_id, expense} -> JS.navigate(~p"/expenses/#{expense}") end}
      >
        <:col :let={{_id, expense}} label="Title">{expense.title}</:col>
        <:col :let={{_id, expense}} label="Amount">{expense.amount}</:col>
        <:col :let={{_id, expense}} label="Category">{expense.category}</:col>
        <:col :let={{_id, expense}} label="Date">{expense.date}</:col>
        <:action :let={{_id, expense}}>
          <div class="sr-only">
            <.link navigate={~p"/expenses/#{expense}"}>Show</.link>
          </div>
          <.link navigate={~p"/expenses/#{expense}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, expense}}>
          <.link
            phx-click={JS.push("delete", value: %{id: expense.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Expenses")
     |> stream(:expenses, list_expenses(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    expense = Accounting.get_expense!(scope, id)
    {:ok, _} = Accounting.delete_expense(scope, expense)

    {:noreply, stream_delete(socket, :expenses, expense)}
  end

  defp list_expenses(scope) do
    Accounting.list_expenses(scope)
  end
end
