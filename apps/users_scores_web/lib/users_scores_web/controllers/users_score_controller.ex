defmodule UsersScoresWeb.UsersScoreController do
  use UsersScoresWeb, :controller

  def index(conn, _params) do
    %{users: users, timestamp: timestamp} = UsersScores.return_users()

    json(conn, %{users: users, timestamp: timestamp})
  end
end
