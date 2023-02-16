defmodule UsersScoresWeb.UsersScoreControllerTest do
  use UsersScoresWeb.ConnCase, async: true

  alias UsersScores.{PointsUpdater, Repo, User}

  setup do
    allow = Process.whereis(PointsUpdater)
    Ecto.Adapters.SQL.Sandbox.allow(Repo, self(), allow)

    PointsUpdater.clean_state()

    date_time_utc_now = DateTime.truncate(DateTime.utc_now(), :second)
    Ecto.Adapters.SQL.query(Repo, "ALTER SEQUENCE users_id_seq RESTART WITH 1")
    params = %{inserted_at: date_time_utc_now, updated_at: date_time_utc_now, points: 50}

    {:ok, params: params}
  end

  describe "index" do
    test "returns users matching criteria and updates timestamp", %{conn: conn, params: params} do
      assert %{
               "timestamp" => nil,
               "users" => []
             } =
               conn
               |> get("/")
               |> json_response(200)

      User.Mutator.create_users(1, params)

      assert %{
               "timestamp" => timestamp_1,
               "users" => [
                 %{"id" => 1, "points" => 50}
               ]
             } =
               conn
               |> get("/")
               |> json_response(200)

      User.Mutator.create_users(100, params)

      assert %{
               "timestamp" => timestamp_2,
               "users" => [
                 %{"id" => id_1, "points" => 50},
                 %{"id" => id_2, "points" => 50}
               ]
             } =
               conn
               |> get("/")
               |> json_response(200)

      assert is_integer(id_1)
      assert is_integer(id_2)
      assert is_binary(timestamp_1)
      assert is_binary(timestamp_2)
    end
  end
end
