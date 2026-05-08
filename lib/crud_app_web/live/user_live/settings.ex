defmodule CrudAppWeb.UserLive.Settings do
  use CrudAppWeb, :live_view

  on_mount {CrudAppWeb.UserAuth, :require_sudo_mode}

  alias CrudApp.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div class="mb-10 border-b border-base-300 pb-5">
          <h1 class="text-3xl font-bold tracking-tight text-base-content">Account Settings</h1>
          <p class="mt-2 text-sm text-base-content/70">Manage your account email address, password, and preferences.</p>
        </div>

        <div class="space-y-10">
          
          <!-- Profile Information (Placeholder) -->
          <div class="card bg-base-100 shadow-sm border border-base-300">
            <div class="card-body">
              <h2 class="card-title text-lg font-semibold border-b border-base-200 pb-2 mb-4">Profile Information</h2>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label"><span class="label-text">Full Name</span></label>
                  <input type="text" placeholder="John Doe" class="input input-bordered" disabled />
                </div>
                <div class="form-control">
                  <label class="label"><span class="label-text">Company / Organization</span></label>
                  <input type="text" placeholder="Acme Corp" class="input input-bordered" disabled />
                </div>
              </div>
              <p class="text-xs text-base-content/50 mt-2">Profile fields are managed by your organization administrator.</p>
            </div>
          </div>

          <!-- Email Settings -->
          <div class="card bg-base-100 shadow-sm border border-base-300">
            <div class="card-body">
              <h2 class="card-title text-lg font-semibold border-b border-base-200 pb-2 mb-4">Email Address</h2>
              <.form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email" class="max-w-md space-y-4">
                <.input
                  field={@email_form[:email]}
                  type="email"
                  label="Primary Email"
                  autocomplete="username"
                  spellcheck="false"
                  required
                />
                <div class="mt-4">
                  <.button variant="primary" phx-disable-with="Changing...">Update Email Address</.button>
                </div>
              </.form>
            </div>
          </div>

          <!-- Password Settings -->
          <div class="card bg-base-100 shadow-sm border border-base-300">
            <div class="card-body">
              <div class="flex justify-between items-end border-b border-base-200 pb-2 mb-4">
                <h2 class="card-title text-lg font-semibold">Change Password</h2>
                <.link href={~p"/users/log-out"} method="delete" class="text-xs text-primary hover:underline">Forgot password? Log out to reset</.link>
              </div>
              
              <.form
                for={@password_form}
                id="password_form"
                action={~p"/users/update-password"}
                method="post"
                phx-change="validate_password"
                phx-submit="update_password"
                phx-trigger-action={@trigger_submit}
                class="max-w-md space-y-4"
              >
                <input
                  name={@password_form[:email].name}
                  type="hidden"
                  id="hidden_user_email"
                  spellcheck="false"
                  value={@current_email}
                />
                <.input
                  field={@password_form[:password]}
                  type="password"
                  label="New password"
                  autocomplete="new-password"
                  spellcheck="false"
                  required
                />
                <.input
                  field={@password_form[:password_confirmation]}
                  type="password"
                  label="Confirm new password"
                  autocomplete="new-password"
                  spellcheck="false"
                />
                <div class="mt-4">
                  <.button variant="primary" phx-disable-with="Saving...">Update Password</.button>
                </div>
              </.form>
            </div>
          </div>

          <!-- Notification Preferences -->
          <div class="card bg-base-100 shadow-sm border border-base-300">
            <div class="card-body">
              <h2 class="card-title text-lg font-semibold border-b border-base-200 pb-2 mb-4">Notification Preferences</h2>
              <div class="space-y-4">
                <label class="flex items-center gap-3 cursor-pointer">
                  <input type="checkbox" checked class="checkbox checkbox-primary" />
                  <span class="label-text">Receive weekly analytics reports</span>
                </label>
                <label class="flex items-center gap-3 cursor-pointer">
                  <input type="checkbox" checked class="checkbox checkbox-primary" />
                  <span class="label-text">Security alerts (New logins, password changes)</span>
                </label>
              </div>
            </div>
          </div>

          <!-- Danger Zone -->
          <div class="card bg-error/10 border border-error/30 mt-12">
            <div class="card-body">
              <h2 class="card-title text-error">Danger Zone</h2>
              <p class="text-sm opacity-80 mb-4">Once you delete your account, there is no going back. Please be certain.</p>
              <div>
                <button class="btn btn-error btn-outline" disabled>Delete Account</button>
                <span class="text-xs ml-4 opacity-60">Contact your system admin to delete your workspace.</span>
              </div>
            </div>
          </div>

        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email changed successfully.")

        {:error, _} ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end
end
