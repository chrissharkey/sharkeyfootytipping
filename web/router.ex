defmodule Footy.Router do
  use Footy.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Footy do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/login", AuthController, :login
    post "/login", AuthController, :login_post
    get "/logout", AuthController, :logout
    get "/login/select", AuthController, :select
    get "/join", CompetitionController, :join
    get "/join/:competition_id", CompetitionController, :join_competition
    post "/join/:competition_id", CompetitionController, :join_competition_post
    get "/new", CompetitionController, :new_competition
    post "/new", CompetitionController, :new_competition_post
    get "/competition/:competition_id", CompetitionController, :view_competition
  end

  # Other scopes may use custom stacks.
  # scope "/api", Footy do
  #   pipe_through :api
  # end
end
