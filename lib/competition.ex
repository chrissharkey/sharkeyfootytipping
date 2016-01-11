defmodule Competition do
  import RethinkDB.Query, only: [table_create: 1, table: 1, insert: 2, delete: 1, filter: 2]
  require Logger

  def init() do
    table_create("competitions")
    |> Example.Database.run
  end

  def create_competition(name, player_id) do
    short_name = Regex.replace(~r/[^a-z]/, String.downcase(name), "")
    result2 = exists?(short_name)
    IO.puts result2
    case result2 do
      nil ->
        table("competitions") |> insert(%{short_name: short_name, name: name, owner_id: player_id}) |> Example.Database.run
        {:ok, short_name}
      _ ->
        {:error, "Competition exists"}
    end
  end

  def delete_competition(short_name) do
    table("competitions") |> filter(%{short_name: short_name}) |> delete |> Example.Database.run
  end

  def change_owner(competition_id, player_id) do
  end

  def add_administrator(competition_id, player_id) do
    

  end

  def delete_administrator(competition_id, player_id) do
    
  end

  def is_administrator?(competition_id, player_id) do
    
  end

  def get_ladder do
    

  end

  # Private methods
  defp exists?(short_name) do
    competition = table("competitions")
    |> filter(%{short_name: short_name})
    |> Example.Database.run
    Logger.debug "> competition data #{inspect competition.data.length}"
    competition.data
  end

end
