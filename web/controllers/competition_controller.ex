defmodule Footy.CompetitionController do
  use Footy.Web, :controller

  def join(conn, _params) do
    conn
    |> assign(:competitions, Competition.get_all)
    |> render "join.html"
  end

  def join_competition(conn, params) do
    competition = Competition.get(params["competition_id"])
    unless competition do
      conn
      |> put_status(:not_found)
      |> render(Footy.ErrorView, "404.html")
    else
      conn
      |> assign(:competition, competition)
      |> assign(:logged_in, true)
      |> assign(:competition_member, false)
      |> assign(:player, %{name: "Christopher Sharkey"})
      |> render("join_competition.html")
    end
  end
end
