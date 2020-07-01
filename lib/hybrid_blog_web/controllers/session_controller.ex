defmodule HybridBlogWeb.SessionController do
  use HybridBlogWeb, :controller
  alias HybridBlog.Accounts
  @config_key :assent_providers
  @session_params_key :assent_session_params
  @current_user_key :current_user
  @type conn :: Plug.Conn.t()
  @type params :: Plug.Conn.params()
  @type error :: {:error, Exception.t()}
  @doc """
  The OAuth callback handler.

  Sign in or sign up and redirect to the index page.
  """
  @spec callback(conn, params) :: conn | error
  def callback(conn, %{"provider" => "google"} = params) do
    with {:ok, %{user: user}} <- process_callback(conn, :google, Assent.Strategy.Google, params),
         {:ok, conn} <- sign_in(conn, :google_sub, user) do
      conn |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  @spec process_callback(conn, atom, module, params) :: {:ok, %{user: map}} | error
  defp process_callback(conn, provider, module, params) do
    config!(provider)
    |> Assent.Config.put(:session_params, get_session(conn, @session_params_key)[provider])
    |> module.callback(params)
  end

  @spec sign_in(conn, atom, map) :: conn | error
  defp sign_in(conn, field, %{"sub" => sub} = attrs) do
    if user = Accounts.get_user_by(field, sub) do
      {:ok, put_session(conn, @current_user_key, attrs)}
    else
      sign_up(conn, field, attrs)
    end
  end

  @spec sign_up(conn, atom, map) :: conn | error
  defp sign_up(conn, field, %{"sub" => sub} = attrs) do
    with {:ok, user} <- Accounts.create_user(attrs, [{field, sub}]) do
      {:ok, put_session(conn, @current_user_key, user)}
    end
  end

  @doc """
  Sign out and redirect to the index page.
  """
  @spec sign_out(conn, params) :: conn
  def sign_out(conn, _params) do
    conn |> delete_session(@current_user_key) |> redirect(to: Routes.page_path(conn, :index))
  end

  @doc """
  Returns a JSON including URLs for each OAuth provider. Sets the session parameters at same time.
  """
  @spec authorize_url(conn, params) :: conn | error
  def authorize_url(conn, _params) do
    with {:ok, %{url: google_url, session_params: google_session_params}} <-
           Assent.Strategy.Google.authorize_url(config!(:google)) do
      conn
      |> put_session(@session_params_key, %{google: google_session_params})
      |> json(%{google: google_url})
    end
  end

  @spec config!(atom) :: Assent.Config.t()
  defp config!(provider) do
    Application.fetch_env!(:hybrid_blog, @config_key)[provider]
    |> Assent.Config.put(:redirect_uri, redirect_uri(provider))
  end

  @spec redirect_uri(atom) :: binary
  defp redirect_uri(provider) do
    HybridBlogWeb.Router.Helpers.session_url(HybridBlogWeb.Endpoint, :callback, provider)
  end
end
