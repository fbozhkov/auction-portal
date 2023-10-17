defmodule AuctionWeb.UserForgotPasswordLive do
  use AuctionWeb, :live_view

  alias Auction.Users

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= gettext("Forgot your password?") %>
        <:subtitle>
          <%= gettext("We'll send a password reset link to your inbox") %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="reset_password_form"
        phx-submit="send_email"
      >
        <.input
          field={@form[:email]}
          type="email"
          placeholder={gettext("Email")}
          required
        />
        <:actions>
          <.button phx-disable-with={gettext("Sending...")} class="w-full">
            <%= gettext("Send password reset instructions") %>
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center text-sm mt-4">
        <.link href={~p"/users/register"}><%= gettext("Register") %></.link>
        | <.link href={~p"/users/log_in"}><%= gettext("Log in") %></.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Users.get_user_by_email(email) do
      Users.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      {gettext(
         "If your email is in our system, you will receive instructions to reset your password shortly."
       )}

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
