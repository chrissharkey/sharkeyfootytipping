defmodule Example.CompetitionView do
  use Example.Web, :view

  def competitions do
    Competition.get_all
  end

  def competition_data(competition_id) do
    Competition.get(competition_id)
  end

end
