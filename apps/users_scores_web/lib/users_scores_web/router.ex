defmodule UsersScoresWeb.Router do
  use UsersScoresWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UsersScoresWeb do
    pipe_through :api

    get "/", UsersScoreController, :index
  end
end
