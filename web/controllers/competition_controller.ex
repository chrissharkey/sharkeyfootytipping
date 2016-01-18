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
    render_join_competition(conn, params)
  end

  def join_competition_post(conn, params) do
    case Competition.join(get_session(conn, :session_id), params) do
      {:error, reason} ->
        conn = conn |> put_flash(:error, reason)
        render_join_competition conn, params
      {:invalid, errors} ->
        conn = conn |> put_flash(:error, "Not all of the fields were present and valid, please try again")
        render_join_competition conn, params, errors
      {:ok, competition_id, player_id, msg} ->
        case Player.create_session(player_id) do
          {:ok, session_id} ->
            conn
            |> put_session(:session_id, session_id)
            |> put_flash(:info, msg)
            |> redirect(to: "/competition/#{competition_id}")
          {:error, _} ->
            conn
            |> put_flash(:info, "Competition joined, but there was an error logging you in.")
            |> redirect(to: "/login")
        end
    end
  end

  defp render_join_competition(conn, params, errors \\ %{}) do
    Logger.debug("#{get_session(conn, :session_id)} MY SESSION ID")
    competition = Competition.get(params["competition_id"])
    unless competition do
      conn
      |> put_status(:not_found)
      |> render(Footy.ErrorView, "404.html")
    else
      player = Player.get_by_session(get_session(conn, :session_id))
      Logger.info("Render join competition #{inspect player}")
      conn
      |> assign(:competition, competition)
      |> assign(:player, player)
      |> assign(:errors, errors)
      |> assign(:params, params)
      |> assign(:competition_member, Competition.is_member?(competition["id"], player))
      |> render("join_competition.html")
    end
  end

  def new_competition(conn, params) do
    render_new_competition(conn, params)
  end

  def new_competition_post(conn, params) do
    case Competition.new(get_session(conn, :session_id), params) do
      {:error, reason} ->
        conn = conn |> put_flash(:error, reason)
        render_new_competition conn, params
      {:invalid, errors} ->
        conn = conn |> put_flash(:error, "Not all of the fields were present and valid, please try again")
        render_new_competition conn, params, errors
      {:ok, competition_id, player_id, msg} ->
        case Player.create_session(player_id) do
          {:ok, session_id} ->
            conn
            |> put_session(:session_id, session_id)
            |> put_flash(:info, msg)
            |> redirect(to: "/competition/#{competition_id}")
          {:error, _} ->
            conn
            |> put_flash(:info, "Competition joined, but there was an error logging you in.")
            |> redirect(to: "/login")
        end
    end
  end

  # @TODO: this should be made generic so that it can check these details for any competition page
  # unless we are doing the competition as a 1-page app in which case it doesn't matter.
  def view_competition(conn, params) do
    Logger.debug("#{get_session(conn, :session_id)} MY SESSION ID trying to view competition")
    competition = Competition.get(params["competition_id"])
    unless competition do
      conn
      |> put_status(:not_found)
      |> render(Footy.ErrorView, "404.html")
    else
      player = Player.get_by_session(get_session(conn, :session_id))
      unless Competition.is_member?(competition["id"], player) do
        conn
        |> put_status(:not_found)
        |> render(Footy.ErrorView, "404.html")
      else        
        conn
        |> assign(:competition, competition)
        |> assign(:player, player)
        |> assign(:is_admin, Competition.is_admin?(competition["id"], player))
        |> render("view_competition.html")
      end
    end
  end

  defp render_new_competition(conn, params, errors \\ %{}) do
    player = Player.get_by_session(get_session(conn, :session_id))
    conn
    |> assign(:player, player)
    |> assign(:errors, errors)
    |> assign(:params, params)
    |> render("new_competition.html")
  end

end
