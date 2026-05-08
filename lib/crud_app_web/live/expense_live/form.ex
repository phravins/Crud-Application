defmodule CrudAppWeb.ExpenseLive.Form do
  use CrudAppWeb, :live_view

  alias CrudApp.Accounting
  alias CrudApp.Accounting.Expense

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage expense records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="expense-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <.input field={@form[:category]} type="text" label="Category" />
        <.input field={@form[:date]} type="date" label="Date" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Expense</.button>
          <.button navigate={return_path(@return_to, @expense)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    scope = socket.assigns.current_scope
    expense = Accounting.get_expense!(scope, id)

    socket
    |> assign(:page_title, "Edit Expense")
    |> assign(:expense, expense)
    |> assign(:form, to_form(Accounting.change_expense(scope, expense)))
  end

  defp apply_action(socket, :new, _params) do
    scope = socket.assigns.current_scope
    expense = %Expense{}

    socket
    |> assign(:page_title, "New Expense")
    |> assign(:expense, expense)
    |> assign(:form, to_form(Accounting.change_expense(scope, expense)))
  end

  @impl true
  def handle_event("validate", %{"expense" => expense_params}, socket) do
    scope = socket.assigns.current_scope
    changeset = Accounting.change_expense(scope, socket.assigns.expense, expense_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"expense" => expense_params}, socket) do
    save_expense(socket, socket.assigns.live_action, expense_params)
  end

  defp save_expense(socket, :edit, expense_params) do
    scope = socket.assigns.current_scope
    case Accounting.update_expense(scope, socket.assigns.expense, expense_params) do
      {:ok, expense} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expense updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, expense))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_expense(socket, :new, expense_params) do
    scope = socket.assigns.current_scope
    case Accounting.create_expense(scope, expense_params) do
      {:ok, expense} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expense created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, expense))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _expense), do: ~p"/expenses"
  defp return_path("show", expense), do: ~p"/expenses/#{expense}"
end
