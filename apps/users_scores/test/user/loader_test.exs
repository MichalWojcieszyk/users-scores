defmodule UsersScores.User.LoaderTest do
  use UsersScores.DataCase, async: false

  alias UsersScores.{Repo, User}

  setup do
    date_time_utc_now = DateTime.truncate(DateTime.utc_now(), :second)

    {:ok, date_time_utc_now: date_time_utc_now}
  end

  describe "with_more_points/2" do
    test "returns users with more points then given", %{date_time_utc_now: date_time_utc_now} do
      Repo.insert_all(User, [
        %{points: 20, inserted_at: date_time_utc_now, updated_at: date_time_utc_now},
        %{points: 30, inserted_at: date_time_utc_now, updated_at: date_time_utc_now}
      ])

      assert [%{points: 30}] = User.Loader.with_more_points(21, 1)
    end

    test "returns only given number of users", %{date_time_utc_now: date_time_utc_now} do
      Repo.insert_all(User, [
        %{points: 30, inserted_at: date_time_utc_now, updated_at: date_time_utc_now},
        %{points: 30, inserted_at: date_time_utc_now, updated_at: date_time_utc_now}
      ])

      assert [%{points: 30}] = User.Loader.with_more_points(21, 1)
    end
  end
end
