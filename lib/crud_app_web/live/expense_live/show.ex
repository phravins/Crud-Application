defmodule CrudAppWeb.ExpenseLive.Show do
  use CrudAppWeb, :live_view

  alias CrudApp.Accounting

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Expense {@expense.id}
        <:subtitle>This is a expense record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/expenses"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/expenses/#{@expense}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit expense
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@expense.title}</:item>
        <:item title="Amount">{@expense.amount}</:item>
        <:item title="Category">{@expense.category}</:item>
        <:item title="Date">{@expense.date}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Expense")
     |> assign(:expense, Accounting.get_expense!(id))}
  end
end
