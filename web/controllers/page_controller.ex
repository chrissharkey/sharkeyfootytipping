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
    case Competition.create_competition("Sharkey Footy Tipping Competition", 'aaaaaaaaa') do
      {:ok, short_name} ->
        Competition.delete_competition(short_name)
      {:error, _} ->
        Competition.delete_competition('sharkeyfootytippingcompetition')
      _ ->
        Competition.init
    end

    # |> Example.Database.run
    # |> IO.inspect
    render conn, "index.html"
    # json conn, results
  end
end
