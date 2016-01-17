defmodule Footy.CompetitionView do
  use Footy.Web, :view

  def csrf_token(_conn) do
    get_csrf_token
  end

end
