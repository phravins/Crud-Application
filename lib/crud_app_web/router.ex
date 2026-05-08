defmodule CrudAppWeb.Router do
  use CrudAppWeb, :router

  import CrudAppWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CrudAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CrudAppWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", CrudAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:crud_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CrudAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", CrudAppWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{CrudAppWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      live "/records", RecordLive.Index, :index
      live "/records/new", RecordLive.Form, :new
      live "/records/:id", RecordLive.Show, :show
      live "/records/:id/edit", RecordLive.Form, :edit

      live "/tasks", TaskLive.Index, :index
      live "/tasks/new", TaskLive.Form, :new
      live "/tasks/:id", TaskLive.Show, :show
      live "/tasks/:id/edit", TaskLive.Form, :edit

      live "/expenses", ExpenseLive.Index, :index
      live "/expenses/new", ExpenseLive.Form, :new
      live "/expenses/:id", ExpenseLive.Show, :show
      live "/expenses/:id/edit", ExpenseLive.Form, :edit

      live "/incomes", IncomeLive.Index, :index
      live "/incomes/new", IncomeLive.Form, :new
      live "/incomes/:id", IncomeLive.Show, :show
      live "/incomes/:id/edit", IncomeLive.Form, :edit

      live "/clients", ClientLive.Index, :index
      live "/clients/new", ClientLive.Form, :new
      live "/clients/:id", ClientLive.Show, :show
      live "/clients/:id/edit", ClientLive.Form, :edit

      live "/products", ProductLive.Index, :index
      live "/products/new", ProductLive.Form, :new
      live "/products/:id", ProductLive.Show, :show
      live "/products/:id/edit", ProductLive.Form, :edit

      live "/analytics", AnalyticsLive, :index
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", CrudAppWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{CrudAppWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
