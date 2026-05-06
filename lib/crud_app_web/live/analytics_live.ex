defmodule CrudAppWeb.AnalyticsLive do
  use CrudAppWeb, :live_view

  alias CrudApp.Business

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <.header>
        Business Analytics
        <:subtitle>Aggregated insights from your business records.</:subtitle>
      </.header>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="stats shadow bg-base-200">
          <div class="stat">
            <div class="stat-title">Total Records</div>
            <div class="stat-value text-primary">{@total_records}</div>
            <div class="stat-desc">Across all categories</div>
          </div>
        </div>

        <div class="stats shadow bg-base-200" :for={{category, count} <- @category_distribution}>
          <div class="stat">
            <div class="stat-title">{category}</div>
            <div class="stat-value text-secondary">{count}</div>
            <div class="stat-desc">Records in this category</div>
          </div>
        </div>
      </div>

      <div class="card bg-base-200 shadow-xl mt-8">
        <div class="card-body">
          <h2 class="card-title text-xl mb-4">Unordered Data Analysis</h2>
          <p class="text-sm opacity-70 mb-4">Below is a breakdown of custom metadata fields found across your records.</p>
          
          <div class="overflow-x-auto">
            <table class="table w-full">
              <thead>
                <tr>
                  <th>Field Key</th>
                  <th>Occurrences</th>
                  <th>Example Value</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={{key, count, example} <- @metadata_insights}>
                  <td class="font-mono text-primary">{key}</td>
                  <td>{count}</td>
                  <td class="italic opacity-80">{example}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8 print:p-0">
      <div class="flex justify-between items-center mb-8">
        <.header>
          Business Analytics Dashboard
          <:subtitle>Real-time insights and data visualizations.</:subtitle>
        </.header>
        <div class="flex gap-2">
          <button 
            onclick="window.print()" 
            class="btn btn-outline btn-secondary no-print"
          >
            <.icon name="hero-arrow-down-tray" /> Export PDF
          </button>
        </div>
      </div>

      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div class="stats shadow bg-base-200">
          <div class="stat">
            <div class="stat-title text-sm opacity-70">Total Records</div>
            <div class="stat-value text-primary">{@total_records}</div>
            <div class="stat-desc">Data Points Collected</div>
          </div>
        </div>

        <div class="stats shadow bg-base-200" :for={{category, count} <- Enum.take(@category_distribution, 3)}>
          <div class="stat">
            <div class="stat-title text-sm opacity-70">{category}</div>
            <div class="stat-value text-secondary">{count}</div>
            <div class="stat-desc">Active Entries</div>
          </div>
        </div>
      </div>

      <!-- Charts Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-12">
        <div class="card bg-base-100 shadow-xl border border-base-300">
          <div class="card-body">
            <h2 class="card-title text-lg mb-6">Record Distribution by Category</h2>
            <div class="h-[300px] w-full">
              <canvas 
                id="category-chart" 
                phx-hook="Chart" 
                data-config={Jason.encode!(@category_chart_config)}
              ></canvas>
            </div>
          </div>
        </div>

        <div class="card bg-base-100 shadow-xl border border-base-300">
          <div class="card-body">
            <h2 class="card-title text-lg mb-6">Metadata Field Prevalence</h2>
            <div class="h-[300px] w-full">
              <canvas 
                id="metadata-chart" 
                phx-hook="Chart" 
                data-config={Jason.encode!(@metadata_chart_config)}
              ></canvas>
            </div>
          </div>
        </div>
      </div>

      <!-- Detailed Analysis Table -->
      <div class="card bg-base-100 shadow-xl border border-base-300 mt-12 overflow-hidden">
        <div class="card-body p-0">
          <div class="bg-base-200 p-6">
            <h2 class="card-title text-xl">Unordered Data Insights</h2>
            <p class="text-sm opacity-70">Discovery of custom schema-less fields within your business records.</p>
          </div>
          
          <div class="overflow-x-auto p-6">
            <table class="table w-full">
              <thead>
                <tr>
                  <th>Field Key</th>
                  <th>Occurrences</th>
                  <th>Example Value</th>
                  <th>Coverage</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={{key, count, example} <- @metadata_insights}>
                  <td class="font-mono text-primary font-bold">{key}</td>
                  <td>
                    <div class="badge badge-outline">{count} records</div>
                  </td>
                  <td class="italic opacity-80">{example}</td>
                  <td>
                    <div class="w-full bg-base-200 rounded-full h-1.5">
                      <div class="bg-primary h-1.5 rounded-full" style={"width: #{count * 100 / max(@total_records, 1)}%"}></div>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    records = Business.list_records(socket.assigns.current_scope)
    total_records = length(records)
    
    # 1. Category Distribution
    category_counts = 
      records 
      |> Enum.group_by(& &1.category) 
      |> Enum.map(fn {cat, list} -> {cat || "Uncategorized", length(list)} end)
      |> Enum.sort_by(fn {_, count} -> count end, :desc)

    category_labels = Enum.map(category_counts, &elem(&1, 0))
    category_data = Enum.map(category_counts, &elem(&1, 1))

    category_chart_config = %{
      type: "doughnut",
      data: %{
        labels: category_labels,
        datasets: [%{
          label: "Records",
          data: category_data,
          backgroundColor: ["#570df8", "#f000b8", "#37cdbe", "#3d4451", "#ff9900"],
          borderWidth: 0
        }]
      },
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        plugins: %{
          legend: %{ position: "bottom" }
        }
      }
    }

    # 2. Metadata Insights
    metadata_insights = 
      records
      |> Enum.flat_map(fn r -> Map.keys(r.metadata || %{}) end)
      |> Enum.frequencies()
      |> Enum.map(fn {key, count} -> 
        example_record = Enum.find(records, fn r -> Map.has_key?(r.metadata || %{}, key) end)
        example_value = example_record.metadata[key]
        {key, count, inspect(example_value)}
      end)
      |> Enum.sort_by(fn {_, count, _} -> count end, :desc)

    metadata_labels = Enum.map(Enum.take(metadata_insights, 5), &elem(&1, 0))
    metadata_data = Enum.map(Enum.take(metadata_insights, 5), &elem(&1, 1))

    metadata_chart_config = %{
      type: "bar",
      data: %{
        labels: metadata_labels,
        datasets: [%{
          label: "Field Frequency",
          data: metadata_data,
          backgroundColor: "#570df8",
          borderRadius: 8
        }]
      },
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        scales: %{
          y: %{ beginAtZero: true, grid: %{ display: false } },
          x: %{ grid: %{ display: false } }
        },
        plugins: %{
          legend: %{ display: false }
        }
      }
    }

    {:ok, 
     socket
     |> assign(:page_title, "Analytics Dashboard")
     |> assign(:total_records, total_records)
     |> assign(:category_distribution, category_counts)
     |> assign(:metadata_insights, metadata_insights)
     |> assign(:category_chart_config, category_chart_config)
     |> assign(:metadata_chart_config, metadata_chart_config)}
  end
end
