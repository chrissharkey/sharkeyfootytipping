defmodule Competition do
  import RethinkDB.Query, only: [table: 1, insert: 2, delete: 1, filter: 2]
  require Logger

  def new(session_id, form_input) do
    case Player.find_or_create(session_id, form_input) do
      {:error, reason} -> {:error, reason}
      {:invalid, errors} -> {:invalid, errors}
      {:ok, player_id} -> create_competition(player_id, form_input)
      _ -> {:error, "An unknown error has occurred."}
    end
  end

  def join(session_id, form_input) do
    case Player.find_or_create(session_id, form_input) do
      {:error, reason} -> {:error, reason}
      {:invalid, errors} -> {:invalid, errors}
      {:ok, player_id} -> join_competition(player_id, form_input["competition_id"])
      _ -> {:error, "An unknown error has occurred."}
    end
  end

  def delete_competition(competition_id) do
    table("competitions") 
    |> filter(%{id: competition_id}) 
    |> delete 
    |> Footy.Database.run
  end

  def get_all do
    table("competitions") 
    |> Footy.Database.run
    |> Map.get(:data)
  end

  def get(competition_id) do
    table("competitions")
    |> filter(%{id: competition_id})
    |> Footy.Database.run
    |> Map.get(:data)
    |> List.first
  end
 
  def is_member?(competition_id, player) do
    unless player do
      false
    else
      member = table("competitions_members")
      |> filter(%{competition_id: competition_id, player_id: player["id"]})
      |> Footy.Database.run
      if length(member.data) == 0, do: false, else: true
    end
  end

  def create_competition(player_id, form_input) do
    # @TODO: validate competition name
    short_name = Regex.replace(~r/[^a-z]/, String.downcase(form_input["competition_name"]), "")
    case valid_competition_name?(form_input["competition_name"], short_name) do
      {:invalid, message} -> {:invalid, message}
      {:ok, _} ->
        competition = table("competitions") 
        |> insert(%{short_name: short_name, name: form_input["competition_name"], owner_id: player_id}) 
        |> Footy.Database.run
        Logger.debug "#{inspect competition}, competition is"
        competition_id = "TEMP"
        # @TODO: check result for success here, need to anyway to get the ID
        case join_competition(player_id, competition_id) do
          {:error, reason} -> 
            delete_competition(competition_id)
            {:error, "An error occurred trying to create the competition"}
          {:ok, _} ->
            case make_administrator(player_id, competition_id) do
              {:error, reason} -> 
                delete_competition(competition_id)
                {:error, "An error occurred trying to create the competition"}
              {:ok, _} -> {:ok, "Competition created"}
            end
        end
    end
  end

  def join_competition(player_id, competition_id) do
    unless exists?(competition_id) do
      {:error, "You tried to join a competition which doesn't exist."}
    else
      table("competitions_players")
      |> insert(%{competition_id: competition_id, player_id: player_id})
      |> Footy.Database.run
      |> Map.get(:data)
      if result["inserted"] == 1 do
        {:ok, "You have joined the competition."}
      else
        {:ok, "Error joining the competition."}
      end
    end
  end

  def make_administrator(player_id, competition_id) do
    unless exists?(competition_id) do
      {:error, "You tried to set an administrator in a competition which doesn't exist."}
    else
      result = table("competitions_admins")
      |> insert(%{competition_id: competition_id, player_id: player_id})
      |> Footy.Database.run
      |> Map.get(:data)
      if result["inserted"] == 1 do
        {:ok, "Administrator created."}
      else
        {:error, "Error creating Administrator."}
      end
    end
  end

  defp valid_competition_name?(competition_name, short_name) do
    # @TODO: check validity of competition_name
    competition = table("competitions")
    |> filter(%{short_name: short_name})
    |> Footy.Database.run
    if length(competition.data) == 0, do: {:ok, "Valid"}, else: {:invalid, "A competition already exists with that name."}
  end

  defp exists?(id) do
    Logger.debug("CHecking comp #{inspect id}")
    competition = table("competitions")
    |> filter(%{id: id})
    |> Footy.Database.run
    if length(competition.data) == 0, do: false, else: true
  end

end
