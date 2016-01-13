defmodule Footy.PageController do
  use Footy.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
