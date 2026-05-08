defmodule CrudApp.Metabase do
  use Joken.Config

  def dashboard_url(_user_id, user_email) do
    secret = Application.get_env(:crud_app, :metabase)[:secret_key]
    site_url = Application.get_env(:crud_app, :metabase)[:site_url]
    dashboard_id = Application.get_env(:crud_app, :metabase)[:dashboard_id]

    payload = %{
      "resource" => %{"dashboard" => dashboard_id},
      "params" => %{
        "user_email" => [user_email]
      },
      "exp" => DateTime.utc_now() |> DateTime.add(600, :second) |> DateTime.to_unix()
    }

    signer = Joken.Signer.create("HS256", secret)
    {:ok, token, _} = __MODULE__.encode_and_sign(payload, signer)

    "#{site_url}/embed/dashboard/#{token}#bordered=true&titled=false"
  end

  def dashboard_url(user_id) do
    dashboard_url(user_id, nil)
  end

  def dashboard_url do
    dashboard_url(nil)
  end
end
