defmodule CrudAppWeb.ClientLive.Form do
  use CrudAppWeb, :live_view

  alias CrudApp.CRM
  alias CrudApp.CRM.Client

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage client records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="client-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:phone]} type="text" label="Phone" />
        <.input field={@form[:address]} type="textarea" label="Address" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Client</.button>
          <.button navigate={return_path(@return_to, @client)}>Cancel</.button>
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
    client = CRM.get_client!(scope, id)

    socket
    |> assign(:page_title, "Edit Client")
    |> assign(:client, client)
    |> assign(:form, to_form(CRM.change_client(scope, client)))
  end

  defp apply_action(socket, :new, _params) do
    scope = socket.assigns.current_scope
    client = %Client{}

    socket
    |> assign(:page_title, "New Client")
    |> assign(:client, client)
    |> assign(:form, to_form(CRM.change_client(scope, client)))
  end

  @impl true
  def handle_event("validate", %{"client" => client_params}, socket) do
    scope = socket.assigns.current_scope
    changeset = CRM.change_client(scope, socket.assigns.client, client_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"client" => client_params}, socket) do
    save_client(socket, socket.assigns.live_action, client_params)
  end

  defp save_client(socket, :edit, client_params) do
    scope = socket.assigns.current_scope
    case CRM.update_client(scope, socket.assigns.client, client_params) do
      {:ok, client} ->
        {:noreply,
         socket
         |> put_flash(:info, "Client updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, client))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_client(socket, :new, client_params) do
    scope = socket.assigns.current_scope
    case CRM.create_client(scope, client_params) do
      {:ok, client} ->
        {:noreply,
         socket
         |> put_flash(:info, "Client created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, client))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _client), do: ~p"/clients"
  defp return_path("show", client), do: ~p"/clients/#{client}"
end
