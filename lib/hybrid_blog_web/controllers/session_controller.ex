defmodule HybridBlogWeb.SessionController do
  @moduledoc """
  Handles connections around the authentication.

  Session keys:
  * :current_user_id - a binary of the user ID.
  * :assent_session_params - a map of session params for the callback validation.
  * :live_socket_id - when signed in, "users_socket:<user ID>".
  """
  use HybridBlogWeb, :controller
  alias HybridBlog.Accounts
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
    |> Assent.Config.put(:session_params, get_session(conn, :assent_session_params)[provider])
    |> module.callback(params)
  end

  @spec sign_in(conn, atom, map) :: conn | error
  defp sign_in(conn, field, %{"sub" => sub} = attrs) do
    if user = Accounts.get_user_by(field, sub) do
      {:ok, sign_in_with(conn, user)}
    else
      sign_up(conn, field, attrs)
    end
  end

  @spec sign_up(conn, atom, map) :: conn | error
  defp sign_up(conn, field, %{"sub" => sub} = attrs) do
    with {:ok, user} <- Accounts.create_user(attrs, [{field, sub}]) do
      {:ok, sign_in_with(conn, user)}
    end
  end

  @spec sign_in_with(conn, %Accounts.User{}) :: conn
  defp sign_in_with(conn, %{id: user_id}) do
    conn
    |> put_session(:current_user_id, user_id)
    |> put_session(:live_socket_id, "users_socket:#{user_id}")
  end

  @doc """
  Sign out and redirect to the index page.
  """
  @spec sign_out(conn, params) :: conn
  def sign_out(conn, _params) do
    if current_user_id = get_session(conn, :current_user_id) do
      HybridBlogWeb.Endpoint.broadcast("users_socket:#{current_user_id}", "disconnect", %{})
    end

    conn
    |> delete_session(:current_user_id)
    |> delete_session(:live_socket_id)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  @doc """
  Returns a JSON including URLs for each OAuth provider. Sets the session parameters at same time.
  """
  @spec authorize_url(conn, params) :: conn | error
  def authorize_url(conn, _params) do
    with {:ok, %{url: google_url, session_params: google_session_params}} <-
           Assent.Strategy.Google.authorize_url(config!(:google)) do
      conn
      |> put_session(:assent_session_params, %{google: google_session_params})
      |> json(%{google: google_url})
    end
  end

  @spec config!(atom) :: Assent.Config.t()
  defp config!(provider) do
    Application.fetch_env!(:hybrid_blog, :assent_providers)[provider]
    |> Assent.Config.put(:http_adapter, Assent.HTTPAdapter.Mint)
    |> Assent.Config.put(:redirect_uri, redirect_uri(provider))
  end

  @spec redirect_uri(atom) :: binary
  defp redirect_uri(provider) do
    Routes.session_url(HybridBlogWeb.Endpoint, :callback, provider)
  end
end
