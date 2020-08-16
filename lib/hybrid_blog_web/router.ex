defmodule HybridBlogWeb.Router do
  use HybridBlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {HybridBlogWeb.LayoutView, :root}
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :localize do
    plug Cldr.Plug.SetLocale,
      apps: [:cldr, :gettext],
      cldr: HybridBlogWeb.Cldr,
      from: [:path, :session, :accept_language],
      param: "locale",
      session_key: "locale"

    plug :put_locale
  end

  scope "/", HybridBlogWeb do
    pipe_through :browser
    get "/auth/:provider/callback", SessionController, :callback
    get "/auth/signout", SessionController, :sign_out
  end

  # Other scopes may use custom stacks.
  scope "/api", HybridBlogWeb do
    pipe_through :api

    get "/authorize_url", SessionController, :authorize_url
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: HybridBlogWeb.Telemetry
    end
  end

  for {as, path} <- [{false, "/"}, {:i18n, "/:locale"}] do
    scope path, HybridBlogWeb, as: as do
      pipe_through [:browser, :localize]
      get "/", PageController, :index
      live "/users", UserLive.Index, :index
      live "/users/:id", UserLive.Show, :show
      live "/users/:id/edit", UserLive.Show, :edit
      live "/roles", RoleLive.Index, :index
      live "/roles/new", RoleLive.Show, :new
      live "/roles/:id/edit", RoleLive.Show, :edit
      live "/roles/:id", RoleLive.Show, :show
    end
  end

  @spec fetch_current_user(Plug.Conn.t(), any) :: Plug.Conn.t()
  defp fetch_current_user(conn, _options) do
    id = get_session(conn, :current_user_id)
    assign(conn, :current_user, id && HybridBlog.Accounts.get_user_with_roles!(id))
  end

  @spec put_locale(Plug.Conn.t(), any) :: Plug.Conn.t()
  defp put_locale(conn, _options) do
    locale = Gettext.get_locale()
    conn |> assign(:locale, locale) |> put_session(:locale, locale)
  end
end
