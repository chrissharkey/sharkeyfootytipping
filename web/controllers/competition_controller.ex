defmodule Footy.CompetitionController do
  use Footy.Web, :controller
  require Logger

  def join(conn, _params) do
    render conn, "join.html"
  end

  def join_competition(conn, _params) do
    conn
      |> assign(:competition_id, _params["competition_id"])
      |> assign(:logged_in, true)
      |> assign(:competition_member, false)
      |> assign(:player, %{name: "Christopher Sharkey"})
      |> render("join_competition.html")
  end

end
