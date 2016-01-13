defmodule Competition do
  import RethinkDB.Query, only: [table_create: 1, table: 1, insert: 2, delete: 1, filter: 2]
  require Logger
  # Example logging:
  # Logger.debug "> competition data #{inspect length(competition.data)}"

  def init do
    table_create("competitions")
    |> Example.Database.run
  end

  def create_competition(name, player_id) do
    short_name = Regex.replace(~r/[^a-z]/, String.downcase(name), "")
    unless exists?(short_name) do
      table("competitions") |> insert(%{short_name: short_name, name: name, owner_id: player_id}) |> Example.Database.run
      {:ok, short_name}
    else
      {:error, "Competition exists"}
    end
  end

  def delete_competition(competition_id) do
    table("competitions") |> filter(%{id: competition_id}) |> delete |> Example.Database.run
  end

  def get_all do
    tasks = table("competitions") |> Example.Database.run
    tasks.data
  end

  def get(competition_id) do
    competition = table("competitions")
    |> filter(%{id: competition_id})
    |> Example.Database.run
    Logger.debug "> competition data #{inspect hd(competition.data)}"
    hd(competition.data)
  end

  # Private methods
  defp exists?(short_name) do
    competition = table("competitions")
    |> filter(%{short_name: short_name})
    |> Example.Database.run
    if length(competition.data) == 0, do: false, else: true
  end

end
