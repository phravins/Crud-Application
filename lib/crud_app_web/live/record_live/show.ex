defmodule CrudAppWeb.RecordLive.Show do
  use CrudAppWeb, :live_view

  alias CrudApp.Business

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Record {@record.id}
        <:subtitle>This is a record record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/records"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/records/#{@record}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit record
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@record.name}</:item>
        <:item title="Category">{@record.category}</:item>
      </.list>

      <div class="mt-10">
        <h3 class="text-base font-semibold leading-7">Unordered Metadata</h3>
        <div class="mt-4 border-t border-base-300">
          <dl class="divide-y divide-base-300">
            <div :for={{key, value} <- @record.metadata || %{}} class="px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0">
              <dt class="text-sm font-medium leading-6 text-primary">{key}</dt>
              <dd class="mt-1 text-sm leading-6 text-base-content/70 sm:col-span-2 sm:mt-0">{inspect(value)}</dd>
            </div>
            <div :if={Enum.empty?(@record.metadata || %{})} class="px-4 py-6 text-sm text-base-content/50 italic">
              No additional metadata provided.
            </div>
          </dl>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Business.subscribe_records(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Record")
     |> assign(:record, Business.get_record!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %CrudApp.Business.Record{id: id} = record},
        %{assigns: %{record: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :record, record)}
  end

  def handle_info(
        {:deleted, %CrudApp.Business.Record{id: id}},
        %{assigns: %{record: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current record was deleted.")
     |> push_navigate(to: ~p"/records")}
  end

  def handle_info({type, %CrudApp.Business.Record{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
