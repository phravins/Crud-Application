defmodule CrudAppWeb.AnalyticsLive do
  use CrudAppWeb, :live_view

  alias CrudApp.Accounting
  alias CrudApp.Operations
  alias CrudApp.CRM
  alias CrudApp.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8 print:p-0">
      <div class="flex justify-between items-center mb-8">
        <.header>
          Business Analytics Dashboard
          <:subtitle>Real-time insights across your ERP domains.</:subtitle>
        </.header>
        <div class="flex gap-2">
          <button 
            phx-click={JS.dispatch("phx:prepare-print")}
            class="btn btn-outline btn-secondary no-print"
          >
            <.icon name="hero-arrow-down-tray" /> Export PDF
          </button>
        </div>
      </div>

      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div class="stats shadow bg-base-200 border-t-4 border-[#10b981]">
          <div class="stat">
            <div class="stat-figure text-[#10b981]">
              <.icon name="hero-arrow-trending-up" class="w-8 h-8" />
            </div>
            <div class="stat-title text-sm opacity-70">Finance (Income)</div>
            <div class="stat-value text-[#10b981]">{@counts.incomes}</div>
            <div class="stat-desc">Total Revenue Records</div>
          </div>
        </div>
        
        <div class="stats shadow bg-base-200 border-t-4 border-[#ef4444]">
          <div class="stat">
            <div class="stat-figure text-[#ef4444]">
              <.icon name="hero-banknotes" class="w-8 h-8" />
            </div>
            <div class="stat-title text-sm opacity-70">Finance (Expenses)</div>
            <div class="stat-value text-[#ef4444]">{@counts.expenses}</div>
            <div class="stat-desc">Total Expense Records</div>
          </div>
        </div>

        <div class="stats shadow bg-base-200 border-t-4 border-[#3b82f6]">
          <div class="stat">
            <div class="stat-figure text-[#3b82f6]">
              <.icon name="hero-clipboard-document-check" class="w-8 h-8" />
            </div>
            <div class="stat-title text-sm opacity-70">Operations (Tasks)</div>
            <div class="stat-value text-[#3b82f6]">{@counts.tasks}</div>
            <div class="stat-desc">Active Tasks</div>
          </div>
        </div>

        <div class="stats shadow bg-base-200 border-t-4 border-[#8b5cf6]">
          <div class="stat">
            <div class="stat-figure text-[#8b5cf6]">
              <.icon name="hero-users" class="w-8 h-8" />
            </div>
            <div class="stat-title text-sm opacity-70">Sales (Clients)</div>
            <div class="stat-value text-[#8b5cf6]">{@counts.clients}</div>
            <div class="stat-desc">Total Clients CRM</div>
          </div>
        </div>
      </div>

      <!-- Charts Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-12">
        <div class="card bg-base-100 shadow-xl border border-base-300">
          <div class="card-body">
            <h2 class="card-title text-lg mb-6">ERP Domain Data Volume</h2>
            <div class="h-[300px] w-full">
              <canvas 
                id="domain-chart" 
                phx-hook="Chart" 
                data-config={Jason.encode!(@domain_chart_config)}
              ></canvas>
            </div>
          </div>
        </div>

        <!-- Metabase Configuration Insight -->
        <div class="card bg-base-100 shadow-xl border border-base-300">
          <div class="card-body">
            <h2 class="card-title text-lg mb-4 text-[#b32025]">Metabase High-Fidelity Analytics</h2>
            <p class="text-sm opacity-80 mb-4">
              To achieve accurate, real-time financial reporting (e.g., Net Balance tracking, Income vs Expenses over time) and CRM pipeline analysis, connect Metabase to this database.
            </p>
            <ul class="list-disc list-inside text-sm opacity-80 space-y-2 mb-4">
              <li><span class="font-bold text-[#10b981]">Finance Domain:</span> Create Metabase Questions tracking `incomes` against `expenses` to generate Net Balance charts.</li>
              <li><span class="font-bold text-[#8b5cf6]">Sales Domain:</span> Track `clients` acquisition over time.</li>
              <li><span class="font-bold text-[#3b82f6]">Ops Domain:</span> Track `tasks` completion velocity.</li>
            </ul>
            <div class="mt-auto">
              <a href="https://www.metabase.com/" target="_blank" class="btn btn-outline btn-sm">Configure in Metabase</a>
            </div>
          </div>
        </div>
      </div>

      <!-- Metabase Embedded Dashboard Section -->
      <div class="card bg-base-100 shadow-xl border border-base-300 mt-12 overflow-hidden">
        <div class="card-body p-0">
          <div class="bg-base-200 p-6 border-b border-base-300">
            <h2 class="card-title text-xl text-[#b32025]">
              <.icon name="hero-presentation-chart-line" class="w-6 h-6 mr-2" />
              Advanced Analytics (Powered by Metabase)
            </h2>
            <p class="text-sm opacity-70">Embed your exact Sales, Finance, or Operations Metabase dashboard here.</p>
          </div>
          
          <div class="w-full bg-base-100 p-2 relative metabase-container" style="height: 700px;">
            <%= if @metabase_iframe_url do %>
              <iframe
                  src={@metabase_iframe_url}
                  frameborder="0"
                  width="100%"
                  height="100%"
                  allowtransparency
              ></iframe>
            <% else %>
              <div class="flex flex-col items-center justify-center w-full h-full border-2 border-dashed border-base-300 rounded-lg">
                <.icon name="hero-chart-bar-square" class="w-16 h-16 text-base-content/20 mb-4" />
                <h3 class="text-lg font-semibold text-base-content/80">Metabase Dashboard Not Configured</h3>
                <p class="text-sm text-base-content/60 max-w-md text-center mt-2">
                  Once you build your domain-specific dashboards in Metabase, paste the public or signed embed URL into the configuration (`config/dev.exs`) to see your accurate sales and finance graphs here.
                </p>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    
    # Fetch accurate counts from ERP tables scoped to current user
    incomes_count = length(Accounting.list_incomes(scope))
    expenses_count = length(Accounting.list_expenses(scope))
    tasks_count = length(Operations.list_tasks(scope))
    clients_count = length(CRM.list_clients(scope))
    products_count = length(Inventory.list_products(scope))
    
    counts = %{
      incomes: incomes_count,
      expenses: expenses_count,
      tasks: tasks_count,
      clients: clients_count,
      products: products_count
    }

    # ERP Domain Chart with distinct colors for Sales, Finance, Ops
    domain_chart_config = %{
      type: "doughnut",
      data: %{
        labels: ["Finance (Income)", "Finance (Expenses)", "Operations (Tasks)", "Sales (Clients)", "Inventory"],
        datasets: [%{
          label: "Data Volume",
          data: [incomes_count, expenses_count, tasks_count, clients_count, products_count],
          # Distinct domain colors
          backgroundColor: ["#10b981", "#ef4444", "#3b82f6", "#8b5cf6", "#f59e0b"],
          borderWidth: 0
        }]
      },
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        plugins: %{
          legend: %{ position: "right" }
        }
      }
    }

    # Generate secure signed JWT URL for Metabase embedding
    metabase_url =
      try do
        CrudApp.Metabase.dashboard_url(scope.user.id, scope.user.email)
      rescue
        _ -> nil
      end

    {:ok, 
     socket
     |> assign(:page_title, "Analytics Dashboard")
     |> assign(:counts, counts)
     |> assign(:domain_chart_config, domain_chart_config)
     |> assign(:metabase_iframe_url, metabase_url)}
  end
end
