defmodule Competition do
  import RethinkDB.Query, only: [table_create: 1, table: 1, insert: 2, delete: 1, filter: 2]
  require Logger
  # Example logging:
  # Logger.debug "> competition data #{inspect length(competition.data)}"

  def init() do
    table_create("competitions")
    |> Example.Database.run
  end

  def create_competition(name, player_id) do
    short_name = Regex.replace(~r/[^a-z]/, String.downcase(name), "")
    unless exists?(short_name) do
      Logger.debug "> creating the competition: #{inspect name}"
      table("competitions") |> insert(%{short_name: short_name, name: name, owner_id: player_id}) |> Example.Database.run
      {:ok, short_name}
    else
      Logger.debug "> NOT creating the competition: #{inspect name}"
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
    if length(competition.data) == 0 do
      Logger.debug "> competition does not exist: #{inspect length(competition.data)}"
      false
    else
      Logger.debug "> competition does exist: #{inspect length(competition.data)}"
      true
    end
  end

end
