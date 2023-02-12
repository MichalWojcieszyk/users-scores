defmodule UsersScoresWeb.Router do
  use UsersScoresWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", UsersScoresWeb do
    pipe_through :api
  end
end
