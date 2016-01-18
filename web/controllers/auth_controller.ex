defmodule Footy.AuthController do
  use Footy.Web, :controller
  require Logger

  def login(conn, params) do
    player = Player.get_by_session(get_session(conn, :session_id))
    if player do
      conn
      |> redirect(to: "/login/select")
    else
      conn
      |> assign(:params, params)
      |> render "login.html"
    end
  end

  def login_post(conn, params) do
    case Player.login(params["email"], params["password"]) do
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> assign(:params, params)
        |> render "login.html"
      {:ok, session_id} ->
        conn
        |> put_session(:session_id, session_id)
        |> redirect(to: "/login/select")
    end
  end

  def select(conn, _params) do
    player = Player.get_by_session(get_session(conn, :session_id))
    unless player do
      conn
      |> redirect(to: "/logout")
    else
      competitions = Competition.get_competitions_for_player(player["id"])
      if length(competitions) == 1 do
        conn
        |> redirect(to: "/competition/#{Map.get(List.first(competitions), "id")}")
      else
        conn
        |> assign(:player, player)
        |> assign(:competitions, competitions)
        |> render "select.html"
      end
    end
  end

  def logout(conn, params) do
    Player.logout(get_session(conn, :session_id))
    conn
    |> put_session(:session_id, nil)
    |> assign(:params, params)
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: "/login")
  end

end
