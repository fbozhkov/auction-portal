defmodule AuctionWeb.Router do
  use AuctionWeb, :router

  import AuctionWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {AuctionWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(AuctionWeb.Plugs.SetLocale, gettext: AuctionWeb.Gettext, default_locale: "en")
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # Protected routes

  scope "/:locale", AuctionWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :authenticated,
      on_mount: [{AuctionWeb.UserAuth, :ensure_authenticated}, AuctionWeb.RestoreLocale] do
      live("/my_listings", MyListingsLive)
      live("/listings/new", NewListingLive)
    end
  end

  scope "/", AuctionWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
  end

  scope "/:locale", AuctionWeb do
    pipe_through(:browser)

    get("/", PageController, :home)

    live_session :default, on_mount: AuctionWeb.RestoreLocale do
      live("/listings", ListingsLive)
      live("/listings/:id", ListingDetailsLive)
    end
  end

  ## Admin routes

  scope "/:locale/admin", AuctionWeb do
    pipe_through(:browser)

    live("/listings", ListingLive.Index, :index)
    live("/listings/new", ListingLive.Index, :new)
    live("/listings/:id/edit", ListingLive.Index, :edit)

    live("/listings/:id", ListingLive.Show, :show)
    live("/listings/:id/show/edit", ListingLive.Show, :edit)
  end

  # Other scopes may use custom stacks.
  # scope "/api", AuctionWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:auction, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: AuctionWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/:locale", AuctionWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AuctionWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/log_in", UserLoginLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/:locale", AuctionWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{AuctionWeb.UserAuth, :ensure_authenticated}] do
      live("/users/settings", UserSettingsLive, :edit)
      live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email)
    end
  end

  scope "/:locale", AuctionWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{AuctionWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end

  scope "/:locale", AuctionWeb do
    pipe_through([:browser])

    live("/*path", NoPage)
  end
end
