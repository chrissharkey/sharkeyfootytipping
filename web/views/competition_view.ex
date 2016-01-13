defmodule Footy.CompetitionView do
  use Footy.Web, :view

  def competitions do
    Competition.get_all
  end

  def competition_data(competition_id) do
    Competition.get(competition_id)
  end

end
