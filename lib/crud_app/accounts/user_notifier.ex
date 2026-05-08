defmodule CrudApp.Accounts.UserNotifier do
  import Swoosh.Email

  alias CrudApp.Mailer
  alias CrudApp.Accounts.User

  @from_name "REALSME Solutions"

  defp from_email, do: System.get_env("SMTP_FROM_EMAIL", "no-reply@crudapp.com")

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp deliver(recipient, subject, text_content, html_content) do
    email =
      new()
      |> to(recipient)
      |> from({@from_name, from_email()})
      |> subject(subject)
      |> text_body(text_content)
      |> html_body(html_content)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  defp magic_link_html(title, heading, body_lines, url, button_label, footer_note) do
    lines_html = Enum.map_join(body_lines, "", fn line -> "<p style='margin:0 0 12px;'>#{line}</p>" end)

    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
      <title>#{title}</title>
    </head>
    <body style="margin:0;padding:0;background-color:#f4f7f9;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
      <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f4f7f9;padding:40px 10px;">
        <tr>
          <td align="center">
            <table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,0.05);overflow:hidden;">
              <!-- Header -->
              <tr>
                <td style="padding:30px;background-color:#ffffff;border-bottom:1px solid #edf2f7;text-align:center;">
                  <h2 style="margin:0;color:#2d3748;font-size:24px;font-weight:800;letter-spacing:-0.5px;">
                    <span style="color:#b32025;">REAL</span><span style="color:#2d3748;">SME</span>
                  </h2>
                </td>
              </tr>
              <!-- Body -->
              <tr>
                <td style="padding:40px 50px;">
                  <h1 style="margin:0 0 20px;font-size:22px;font-weight:700;color:#1a202c;line-height:1.3;">
                    #{heading}
                  </h1>
                  <div style="color:#4a5568;font-size:16px;line-height:1.6;">
                    #{lines_html}
                  </div>
                  <!-- Button -->
                  <table cellpadding="0" cellspacing="0" style="margin:35px 0;">
                    <tr>
                      <td align="center" style="background-color:#b32025;border-radius:6px;">
                        <a href="#{url}" style="display:inline-block;padding:14px 40px;color:#ffffff;font-size:16px;font-weight:600;text-decoration:none;border-radius:6px;">
                          #{button_label}
                        </a>
                      </td>
                    </tr>
                  </table>
                  <!-- Fallback Link -->
                  <p style="color:#718096;font-size:13px;margin:20px 0 5px;">
                    If the button doesn't work, copy and paste this link into your browser:
                  </p>
                  <p style="color:#3182ce;font-size:13px;word-break:break-all;margin:0;">
                    <a href="#{url}" style="color:#3182ce;text-decoration:none;">#{url}</a>
                  </p>
                </td>
              </tr>
              <!-- Footer -->
              <tr>
                <td style="padding:30px;background-color:#f8fafc;border-top:1px solid #edf2f7;text-align:center;">
                  <p style="margin:0;color:#718096;font-size:12px;line-height:1.5;">
                    #{footer_note}<br/>
                    This link expires in 10 minutes and can only be used once.
                  </p>
                </td>
              </tr>
            </table>
            <!-- Legal -->
            <p style="margin-top:25px;color:#a0aec0;font-size:12px;text-align:center;">
              &copy; #{DateTime.utc_now().year} REALSME Solutions. All rights reserved.
            </p>
          </td>
        </tr>
      </table>
    </body>
    </html>
    """
  end

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    text = """
    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.
    """

    html =
      magic_link_html(
        "Update email instructions",
        "Update your email address",
        [
          "Hi <strong style='color:#e2e8f0;'>#{user.email}</strong>,",
          "We received a request to update your email address. Click the button below to confirm the change."
        ],
        url,
        "Confirm Email Change",
        "If you didn't request this change, you can safely ignore this email."
      )

    deliver(user.email, "Update email instructions", text, html)
  end

  @doc """
  Deliver instructions to log in with a magic link.
  Dispatches to confirmation or magic-link email depending on account state.
  """
  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    text = """
    Hi #{user.email},

    You can log into your account by visiting the URL below:

    #{url}

    If you didn't request this email, please ignore this.
    """

    html =
      magic_link_html(
        "Log in to #{@from_name}",
        "Your magic login link ✨",
        [
          "Hi <strong style='color:#e2e8f0;'>#{user.email}</strong>,",
          "Click the button below to securely log in to your account. No password needed!"
        ],
        url,
        "Log In Now",
        "If you didn't request this email, you can safely ignore it."
      )

    deliver(user.email, "Your #{@from_name} login link", text, html)
  end

  defp deliver_confirmation_instructions(user, url) do
    text = """
    Hi #{user.email},

    Welcome to #{@from_name}! Please confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.
    """

    html =
      magic_link_html(
        "Confirm your #{@from_name} account",
        "Welcome to #{@from_name}! 🎉",
        [
          "Hi <strong style='color:#e2e8f0;'>#{user.email}</strong>,",
          "Thanks for signing up! Click the button below to confirm your account and get started.",
          "Once confirmed, you'll be automatically logged in."
        ],
        url,
        "Confirm My Account",
        "If you didn't create an account with us, you can safely ignore this email."
      )

    deliver(user.email, "Confirm your #{@from_name} account", text, html)
  end
end
