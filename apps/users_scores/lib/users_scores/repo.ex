defmodule UsersScores.Repo do
  use Ecto.Repo,
    otp_app: :users_scores,
    adapter: Ecto.Adapters.Postgres
end
