defmodule Database do
  import RethinkDB.Query, only: [table_create: 1]

  def migrate do
    table_create("competitions") |> Footy.Database.run
    table_create("players")      |> Footy.Database.run
    table_create("sessions")     |> Footy.Database.run
  end

end