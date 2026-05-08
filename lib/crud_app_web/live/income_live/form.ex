defmodule CrudAppWeb.IncomeLive.Form do
  use CrudAppWeb, :live_view

  alias CrudApp.Accounting
  alias CrudApp.Accounting.Income

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage income records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="income-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <.input field={@form[:source]} type="text" label="Source" />
        <.input field={@form[:date]} type="date" label="Date" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Income</.button>
          <.button navigate={return_path(@return_to, @income)}>Cancel</.button>
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
    income = Accounting.get_income!(scope, id)

    socket
    |> assign(:page_title, "Edit Income")
    |> assign(:income, income)
    |> assign(:form, to_form(Accounting.change_income(scope, income)))
  end

  defp apply_action(socket, :new, _params) do
    scope = socket.assigns.current_scope
    income = %Income{}

    socket
    |> assign(:page_title, "New Income")
    |> assign(:income, income)
    |> assign(:form, to_form(Accounting.change_income(scope, income)))
  end

  @impl true
  def handle_event("validate", %{"income" => income_params}, socket) do
    scope = socket.assigns.current_scope
    changeset = Accounting.change_income(scope, socket.assigns.income, income_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"income" => income_params}, socket) do
    save_income(socket, socket.assigns.live_action, income_params)
  end

  defp save_income(socket, :edit, income_params) do
    scope = socket.assigns.current_scope
    case Accounting.update_income(scope, socket.assigns.income, income_params) do
      {:ok, income} ->
        {:noreply,
         socket
         |> put_flash(:info, "Income updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, income))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_income(socket, :new, income_params) do
    scope = socket.assigns.current_scope
    case Accounting.create_income(scope, income_params) do
      {:ok, income} ->
        {:noreply,
         socket
         |> put_flash(:info, "Income created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, income))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _income), do: ~p"/incomes"
  defp return_path("show", income), do: ~p"/incomes/#{income}"
end
