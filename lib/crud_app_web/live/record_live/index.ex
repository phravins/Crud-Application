defmodule CrudAppWeb.RecordLive.Index do
  use CrudAppWeb, :live_view

  alias CrudApp.Business

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Business Records
        <:subtitle>Manage and organize your data entries.</:subtitle>
        <:actions>
          <.button variant="primary" navigate={~p"/records/new"} class="btn btn-primary shadow-lg">
            <.icon name="hero-plus" class="mr-1" /> New Business Record
          </.button>
        </:actions>
      </.header>

      <.table
        id="records"
        rows={@streams.records}
        row_click={fn {_id, record} -> JS.navigate(~p"/records/#{record}") end}
      >
        <:col :let={{_id, record}} label="Name">{record.name}</:col>
        <:col :let={{_id, record}} label="Category">{record.category}</:col>
        <:col :let={{_id, record}} label="Metadata Items">
          <span class="badge badge-sm badge-outline">
            {Enum.count(record.metadata || %{})} fields
          </span>
        </:col>
        <:action :let={{_id, record}}>
          <div class="sr-only">
            <.link navigate={~p"/records/#{record}"}>Show</.link>
          </div>
          <.link navigate={~p"/records/#{record}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, record}}>
          <.link
            phx-click={JS.push("delete", value: %{id: record.id}) |> hide("##{id}")}
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
    if connected?(socket) do
      Business.subscribe_records(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Records")
     |> stream(:records, list_records(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    record = Business.get_record!(socket.assigns.current_scope, id)
    {:ok, _} = Business.delete_record(socket.assigns.current_scope, record)

    {:noreply, stream_delete(socket, :records, record)}
  end

  @impl true
  def handle_info({type, %CrudApp.Business.Record{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :records, list_records(socket.assigns.current_scope), reset: true)}
  end

  defp list_records(current_scope) do
    Business.list_records(current_scope)
  end
end
