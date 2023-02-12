defmodule UsersScores.PointsUpdaterTest do
  use ExUnit.Case, async: true
  alias UsersScores.{Repo, User}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(UsersScores.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    date_time_utc_now = DateTime.truncate(DateTime.utc_now(), :second)
    params = %{inserted_at: date_time_utc_now, updated_at: date_time_utc_now, points: 50}
    :ok = User.Mutator.create_users(100, params)

    :ok
  end

  describe "return_users/0" do
    test "returns users from database and updates timestamp" do
      assert %{timestamp: nil, users: [%{points: 50}, %{points: 50}]} =
               GenServer.call(PointsState, :return)

      assert %{min_number: 40, timestamp: %DateTime{}} =
               PointsState |> Process.whereis() |> :sys.get_state()
    end
  end
end
