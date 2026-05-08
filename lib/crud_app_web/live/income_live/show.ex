defmodule CrudAppWeb.IncomeLive.Show do
  use CrudAppWeb, :live_view

  alias CrudApp.Accounting

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Income {@income.id}
        <:subtitle>This is a income record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/incomes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/incomes/#{@income}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit income
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@income.title}</:item>
        <:item title="Amount">{@income.amount}</:item>
        <:item title="Source">{@income.source}</:item>
        <:item title="Date">{@income.date}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Income")
     |> assign(:income, Accounting.get_income!(id))}
  end
end
