defmodule Player do
  import RethinkDB.Query, only: [table: 1, insert: 2, delete: 1, filter: 2]
  import Comeonin.Bcrypt
  require Logger
  require String

  def login(email, password) do
    player = get_by_email(email)
    if player and checkpw(password, player.hashed_password) do
      # @TODO: in controller we need to conn = put_session(conn, :sessionid, "bar")      
      create_session(player.id)
    else
      {:error, "Invalid login"}
    end
  end

  def logout(session_id) do
    table("sessions")
    |> filter(%{session_id: session_id})
    |> delete
  end

  def find_or_create(session_id, form_input) do
    player = get_by_session(session_id)
    if player do
      if form_input["email"] do
        {:error, "An error has occurred."}
      else
        {:ok, player["id"]}
      end
    else
      new(form_input)
    end
  end

  def get_by_session(session_id) do
    table("sessions")
    |> filter(%{session_id: session_id})
    |> Footy.Database.run
    |> Map.get(:data)
    |> List.first
  end

  defp get_by_email(email) do
    table("players")
    |> filter(%{email: clean_email(email)})
    |> Footy.Database.run
    |> Map.get(:data)
    |> List.first
  end

  defp new(form_input) do
    case validate_form_input(form_input) do
      {:invalid, errors} -> {:invalid, errors}
      {:valid, new_player} ->
        case player_exists?(new_player) do
          {:error, reason} -> {:error, reason}
          {:ok, true} -> {:error, "Player already exists"}
          {:ok, false} -> create_player(new_player)
        end
    end
  end

  defp create_player(player) do
    result = table("players")
    |> insert(%{first: player["first"], last: player["last"], nickname: player["nickname"], email: clean_email(player["email"]), mobile: player["mobile"], hashed_password: hashpwsalt(player["password"])})
    |> Footy.Database.run
    |> Map.get(:data)
    if result["inserted"] == 1 do
      {:ok, List.first(result["generated_keys"])}
    else
      {:error, "Error creating player."}
    end
  end

  defp player_exists?(player) do
    response = table("players")
    |> filter(%{email: player["email"]})
    |> Footy.Database.run
    |> Map.get(:data)
    if response["e"] do
      {:error, "Database error"}
    else
      if length(response) > 0 do
        {:ok, true}
      else
        {:ok, false}
      end
    end
  end

  defp create_session(player_id) do
    Logger.debug "current time is #{Calendar.DateTime.now_utc}"
    session_id = UUID.uuid1()
    result = table("sessions")
    |> insert(%{session_id: session_id, player_id: player_id, created_at: Calendar.DateTime.now_utc})
    |> Footy.Database.run
    Logger.debug "result of doing this", result
    {:ok, session_id}
  end

  defp clean_email(email) do
    email |> String.downcase
  end

  defp validate_form_input(form_input) do
    fields = %{first: 3, last: 3, nickname: 4, email: 5, mobile: 0, password: 5}
    results = Enum.map Map.keys(fields), fn field ->
      unless String.length(form_input[Atom.to_string(field)]) >= fields[field] do
        {:invalid, field, "Must be at least #{fields[field]} characters"}
      else
        case field do
          :email -> 
            case Regex.run(~r/^[a-z0-9_\-\.]{2,}@[a-z0-9_\-\.]{2,}\.[a-z]{2,}/, form_input[Atom.to_string(field)]) do
              [email] -> {:valid, field}
              _ -> {:invalid, field, "Email address is not valid"}
            end
          _ -> {:valid, field}
        end
      end
    end
    errors = Enum.reduce results, %{}, fn result, acc ->
      if elem(result, 0) == :invalid do
        Map.put(acc, elem(result, 1), result)
      else
        acc
      end
    end
    if length(Map.keys(errors)) > 0 do
      {:invalid, errors}
    else
      {:valid, form_input}
    end
  end

end
