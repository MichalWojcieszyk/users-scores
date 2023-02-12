# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     UsersScores.Repo.insert!(%UsersScores.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias UsersScores.User

date_time_utc_now = DateTime.truncate(DateTime.utc_now(), :second)
params = %{inserted_at: date_time_utc_now, updated_at: date_time_utc_now}

IO.puts("There will be 1000000 users created")

User.Mutator.create_users(1_000_000, params)

IO.puts("There are 1000000 users created in database with 0 as a points score")
