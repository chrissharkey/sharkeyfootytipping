defmodule Competition do
  import RethinkDB.Query, only: [table: 1, insert: 2, delete: 1, filter: 2, eq_join: 4, zip: 1]
  require Logger

  def new(session_id, form_input) do
    short_name = get_short_name(form_input["competition_name"])
    case valid_competition_name?(form_input["competition_name"], short_name) do
      {:invalid, reason} -> {:invalid, %{"competition_name": {:invalid, "competition_name", reason}}}
      {:ok, _} ->
        case Player.find_or_create(session_id, form_input) do
          {:error, reason} -> {:error, reason}
          {:invalid, errors} -> {:invalid, errors}
          {:ok, player_id} -> create_competition(player_id, form_input)
          _ -> {:error, "An unknown error has occurred."}
        end
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
    competitions = table("competitions") 
    |> Footy.Database.run
    |> Map.get(:data)
    unless competitions do
      []
    else
      competitions
    end
  end

  def get_competitions_for_player(player_id) do
    competitions = table("competitions_players")
    |> filter(%{player_id: player_id})
    |> eq_join("competition_id", table("competitions"), %{index: "id"})
    |> zip
    |> Footy.Database.run
    |> Map.get(:data)
    unless competitions do
      []
    else
      competitions
    end
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
      member = table("competitions_players")
      |> filter(%{competition_id: competition_id, player_id: player["id"]})
      |> Footy.Database.run
      if length(member.data) == 0, do: false, else: true
    end
  end

  def is_admin?(competition_id, player) do
    unless player do
      false
    else
      member = table("competitions_admins")
      |> filter(%{competition_id: competition_id, player_id: player["id"]})
      |> Footy.Database.run
      if length(member.data) == 0, do: false, else: true
    end
  end

  def create_competition(player_id, form_input) do
    short_name = get_short_name(form_input["competition_name"])
    case valid_competition_name?(form_input["competition_name"], short_name) do
      {:invalid, reason} -> {:invalid, %{"competition_name": {:invalid, "competition_name", reason}}}
      {:ok, _} ->
        result = table("competitions") 
        |> insert(%{short_name: short_name, name: form_input["competition_name"], owner_id: player_id}) 
        |> Footy.Database.run
        |> Map.get(:data)
        unless result["inserted"] == 1 do
          {:error, "Could not create competition."}
        else
          competition_id = List.first(result["generated_keys"])
          case join_competition(player_id, competition_id) do
            {:error, reason} -> 
              delete_competition(competition_id)
              {:error, "An error occurred trying to create the competition: #{reason}"}
            {:ok, competition_id, player_id, _} ->
              case make_administrator(player_id, competition_id) do
                {:error, reason} -> 
                  delete_competition(competition_id)
                  {:error, "An error occurred trying to create the competition: #{reason}"}
                {:ok, _} -> {:ok, competition_id, player_id, "Competition created."}
              end
          end
        end
    end
  end

  def join_competition(player_id, competition_id) do
    unless exists?(competition_id) do
      {:error, "You tried to join a competition which doesn't exist."}
    else
      result = table("competitions_players")
      |> insert(%{competition_id: competition_id, player_id: player_id})
      |> Footy.Database.run
      |> Map.get(:data)
      Logger.debug("joining competition #{inspect result}")
      if result["inserted"] == 1 do
        {:ok, competition_id, player_id, "You have joined the competition."}
      else
        {:error, "Error joining the competition."}
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
    unless String.length(competition_name) > 7 do
      {:invalid, "Must be at least 8 characters."}
    else
      competition = table("competitions")
      |> filter(%{short_name: short_name})
      |> Footy.Database.run
      if length(competition.data) == 0, do: {:ok, "Valid"}, else: {:invalid, "A competition already exists with that name."}
    end
  end

  defp exists?(id) do
    competition = table("competitions")
    |> filter(%{id: id})
    |> Footy.Database.run
    if length(competition.data) == 0, do: false, else: true
  end

  defp get_short_name(competition_name) do
    Regex.replace(~r/[^a-z]/, String.downcase(competition_name), "")
  end

end
