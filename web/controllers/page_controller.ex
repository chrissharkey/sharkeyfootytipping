defmodule Example.PageController do
  use Example.Web, :controller
  import RethinkDB.Query, only: [table_create: 1, table: 2, table: 1, insert: 2]
  #import RethinkDB.Query, except: [json: 2]

  # setup table and add posts
  def init(conn, _params) do
    table_create("posts")
    |> Example.Database.run

    table("posts") |> insert(%{title: "Python"}) |> Example.Database.run
    table("posts") |> insert(%{title: "Elixir"}) |> Example.Database.run

    text conn, "Posts table created. Visit '/' to fetch posts"
  end

  # fetch all posts and return them as JSON
  def index(conn, _params) do
    Competition.init
    Competition.create_competition("Sharkey Footy Tipping Competition", 'aaaaaaaaa')
    render conn, "index.html"
  end
end
