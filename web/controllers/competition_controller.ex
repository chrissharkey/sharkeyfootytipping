defmodule Footy.CompetitionController do
  use Footy.Web, :controller
  require Logger

  def join(conn, _params) do
    Database.migrate
    conn
    |> assign(:competitions, Competition.get_all)
    |> render "join.html"
  end

  def join_competition(conn, params) do
    render_competition(conn, params)
  end

  def join_competition_post(conn, params) do
    case Competition.join(get_session(conn, :session_id), params) do
      {:error, reason} ->
        conn = conn |> put_flash(:error, reason)
        render_competition conn, params
      {:invalid, errors} ->
        conn = conn |> put_flash(:error, "Not all of the fields were present and valid, please try again")
        render_competition conn, params, errors
      {:ok, msg} ->
        conn
        |> put_flash(:info, msg)
        |> redirect(to: "/competition/#{params["competition_id"]}")
    end
  end

  defp render_competition(conn, params, errors \\ %{}) do
    competition = Competition.get(params["competition_id"])
    unless competition do
      conn
      |> put_status(:not_found)
      |> render(Footy.ErrorView, "404.html")
    else
      player = Player.get_by_session(get_session(conn, :session_id))
      conn
      |> assign(:competition, competition)
      |> assign(:player, player)
      |> assign(:errors, errors)
      |> assign(:params, params)
      |> assign(:competition_member, Competition.is_member?(competition["id"], player))
      |> render("join_competition.html")
    end
  end

end
