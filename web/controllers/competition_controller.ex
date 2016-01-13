defmodule Example.CompetitionController do
  use Example.Web, :controller

  def join(conn, _params) do
    render conn, "join.html"
  end

end
