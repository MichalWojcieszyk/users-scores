defmodule UsersScores.User.MutatorTest do
  use UsersScores.DataCase, async: false

  import Ecto.Query, only: [from: 2]

  alias UsersScores.{Repo, User}

  setup do
    Ecto.Adapters.SQL.query(Repo, "ALTER SEQUENCE users_id_seq RESTART WITH 1")

    date_time_utc_now = User.Helpers.timestamp_utc_now()
    params = %{inserted_at: date_time_utc_now, updated_at: date_time_utc_now}

    {:ok, params: params}
  end

  describe "create_users/2" do
    test "creates requested number of users", %{params: params} do
      :ok = User.Mutator.create_users(1_000_000, params)
      assert Repo.aggregate(User, :count) == 1_000_000
    end
  end

  describe "update_users_points/0" do
    test "sets random number for all users points", %{params: params} do
      :ok = User.Mutator.create_users(1000, params)
      refute Repo.exists?(from u in User, where: u.points > 0)

      :ok = User.Mutator.update_users_points(1, 1000, 10)
      assert Repo.exists?(from u in User, where: u.points > 0)
    end
  end
end
