defmodule Example.CompetitionView do
  use Example.Web, :view

  def competitions do
    Competition.get_all
  end

end
