defmodule CrudAppWeb.RecordLive.Form do
  use CrudAppWeb, :live_view

  alias CrudApp.Business
  alias CrudApp.Business.Record

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-3xl mx-auto py-10">
        <.header>
          {@page_title}
          <:subtitle>Organize your business data with flexible attributes.</:subtitle>
        </.header>

        <div class="mt-10 bg-base-100 p-8 rounded-2xl shadow-xl border border-base-300">
          <.form for={@form} id="record-form" phx-change="validate" phx-submit="save" class="space-y-8">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <.input field={@form[:name]} type="text" label="Record Name" placeholder="e.g. Q4 Sales Report" />
              <.input field={@form[:category]} type="select" label="Category" options={["Sales", "Operations", "Finance", "Legal", "Marketing", "Other"]} />
            </div>

            <div class="divider">Custom Business Data (JSONB)</div>
            
            <div class="space-y-4">
              <div class="flex justify-between items-center">
                <h3 class="text-sm font-semibold uppercase tracking-wider opacity-60">Additional Attributes</h3>
                <button type="button" phx-click="add-metadata" class="btn btn-sm btn-ghost text-primary">
                  <.icon name="hero-plus-circle" /> Add Field
                </button>
              </div>

              <div id="metadata-entries" class="space-y-3">
                <div :for={{entry, index} <- Enum.with_index(@metadata_entries)} class="flex gap-4 items-end animate-in fade-in slide-in-from-left-2">
                  <div class="flex-1">
                    <label class="label text-xs">Field Name</label>
                    <input 
                      type="text" 
                      value={entry["key"]} 
                      phx-blur="update-metadata-key" 
                      phx-value-index={index}
                      class="input input-bordered w-full input-sm" 
                      placeholder="Key"
                    />
                  </div>
                  <div class="flex-[2]">
                    <label class="label text-xs">Value</label>
                    <input 
                      type="text" 
                      value={entry["value"]} 
                      phx-blur="update-metadata-value" 
                      phx-value-index={index}
                      class="input input-bordered w-full input-sm" 
                      placeholder="Value"
                    />
                  </div>
                  <button type="button" phx-click="remove-metadata" phx-value-index={index} class="btn btn-sm btn-square btn-ghost text-error">
                    <.icon name="hero-trash" class="size-4" />
                  </button>
                </div>
                
                <div :if={Enum.empty?(@metadata_entries)} class="text-center py-8 border-2 border-dashed border-base-300 rounded-xl opacity-50 italic text-sm">
                  No additional attributes. Click "Add Field" to include unordered data.
                </div>
              </div>
            </div>

            <div class="pt-6 border-t border-base-300 flex justify-end gap-3">
              <.button navigate={return_path(@current_scope, @return_to, @record)} class="btn btn-ghost">Cancel</.button>
              <.button phx-disable-with="Saving..." class="btn btn-primary px-8">
                <.icon name="hero-check" class="mr-2" /> Save Business Record
              </.button>
            </div>
          </.form>
        </div>
      </div>
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
    record = Business.get_record!(socket.assigns.current_scope, id)
    metadata_entries = 
      (record.metadata || %{})
      |> Enum.map(fn {k, v} -> %{"key" => k, "value" => to_string(v)} end)

    socket
    |> assign(:page_title, "Edit Business Record")
    |> assign(:record, record)
    |> assign(:metadata_entries, metadata_entries)
    |> assign(:form, to_form(Business.change_record(socket.assigns.current_scope, record)))
  end

  defp apply_action(socket, :new, _params) do
    record = %Record{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "Create New Business Record")
    |> assign(:record, record)
    |> assign(:metadata_entries, [])
    |> assign(:form, to_form(Business.change_record(socket.assigns.current_scope, record)))
  end

  @impl true
  def handle_event("add-metadata", _, socket) do
    new_entries = socket.assigns.metadata_entries ++ [%{"key" => "", "value" => ""}]
    {:noreply, assign(socket, metadata_entries: new_entries)}
  end

  @impl true
  def handle_event("remove-metadata", %{"index" => index}, socket) do
    new_entries = List.delete_at(socket.assigns.metadata_entries, String.to_integer(index))
    {:noreply, assign(socket, metadata_entries: new_entries)}
  end

  @impl true
  def handle_event("update-metadata-key", %{"index" => index, "value" => value}, socket) do
    new_entries = List.update_at(socket.assigns.metadata_entries, String.to_integer(index), &Map.put(&1, "key", value))
    {:noreply, assign(socket, metadata_entries: new_entries)}
  end

  @impl true
  def handle_event("update-metadata-value", %{"index" => index, "value" => value}, socket) do
    new_entries = List.update_at(socket.assigns.metadata_entries, String.to_integer(index), &Map.put(&1, "value", value))
    {:noreply, assign(socket, metadata_entries: new_entries)}
  end

  @impl true
  def handle_event("validate", %{"record" => record_params}, socket) do
    changeset = Business.change_record(socket.assigns.current_scope, socket.assigns.record, record_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"record" => record_params}, socket) do
    # Merge metadata entries back into the params
    metadata = 
      socket.assigns.metadata_entries
      |> Enum.reject(fn e -> e["key"] == "" end)
      |> Map.new(fn e -> {e["key"], e["value"]} end)
    
    record_params = Map.put(record_params, "metadata", metadata)
    save_record(socket, socket.assigns.live_action, record_params)
  end

  defp save_record(socket, :edit, record_params) do
    case Business.update_record(socket.assigns.current_scope, socket.assigns.record, record_params) do
      {:ok, record} ->
        {:noreply,
         socket
         |> put_flash(:info, "Record updated successfully")
         |> push_navigate(to: return_path(socket.assigns.current_scope, socket.assigns.return_to, record))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_record(socket, :new, record_params) do
    case Business.create_record(socket.assigns.current_scope, record_params) do
      {:ok, record} ->
        {:noreply,
         socket
         |> put_flash(:info, "Record created successfully")
         |> push_navigate(to: return_path(socket.assigns.current_scope, socket.assigns.return_to, record))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _record), do: ~p"/records"
  defp return_path(_scope, "show", record), do: ~p"/records/#{record}"
end
