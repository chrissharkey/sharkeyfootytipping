defmodule Footy.CompetitionView do
  use Footy.Web, :view

  def csrf_token(conn) do
    get_csrf_token
  end

end
