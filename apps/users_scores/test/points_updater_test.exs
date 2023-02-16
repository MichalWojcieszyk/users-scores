defmodule UsersScores.PointsUpdaterTest do
  use ExUnit.Case, async: true

  alias UsersScores.{PointsUpdater, Repo, User}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(UsersScores.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    PointsUpdater.clean_state()

    date_time_utc_now = DateTime.truncate(DateTime.utc_now(), :second)
    params = %{inserted_at: date_time_utc_now, updated_at: date_time_utc_now, points: 50}
    :ok = User.Mutator.create_users(100, params)
  end

  describe "return_users/0" do
    test "returns users from database and updates timestamp" do
      assert %{timestamp: nil, users: [%{points: 50}, %{points: 50}]} =
               PointsUpdater.return_users()

      assert %{min_number: 40, timestamp: %DateTime{}} =
               PointsUpdater |> Process.whereis() |> :sys.get_state()
    end
  end

  describe "clean_state/0" do
    test "cleans points updater states to default values" do
      assert %{timestamp: nil, users: [%{points: 50}, %{points: 50}]} =
               PointsUpdater.return_users()

      PointsUpdater.clean_state()

      assert %{min_number: 40, timestamp: nil} =
               PointsUpdater |> Process.whereis() |> :sys.get_state()
    end
  end
end
