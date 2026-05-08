defmodule CrudAppWeb.IncomeLive.Index do
  use CrudAppWeb, :live_view

  alias CrudApp.Accounting

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Incomes
        <:actions>
          <.button variant="primary" navigate={~p"/incomes/new"}>
            <.icon name="hero-plus" /> New Income
          </.button>
        </:actions>
      </.header>

      <.table
        id="incomes"
        rows={@streams.incomes}
        row_click={fn {_id, income} -> JS.navigate(~p"/incomes/#{income}") end}
      >
        <:col :let={{_id, income}} label="Title">{income.title}</:col>
        <:col :let={{_id, income}} label="Amount">{income.amount}</:col>
        <:col :let={{_id, income}} label="Source">{income.source}</:col>
        <:col :let={{_id, income}} label="Date">{income.date}</:col>
        <:action :let={{_id, income}}>
          <div class="sr-only">
            <.link navigate={~p"/incomes/#{income}"}>Show</.link>
          </div>
          <.link navigate={~p"/incomes/#{income}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, income}}>
          <.link
            phx-click={JS.push("delete", value: %{id: income.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Incomes")
     |> stream(:incomes, list_incomes(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope
    income = Accounting.get_income!(scope, id)
    {:ok, _} = Accounting.delete_income(scope, income)

    {:noreply, stream_delete(socket, :incomes, income)}
  end

  defp list_incomes(scope) do
    Accounting.list_incomes(scope)
  end
end
