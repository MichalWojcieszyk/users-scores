defmodule UsersScores.User.Mutator do
  alias UsersScores.{Repo, User}

  @spec create_users(integer(), map()) :: :ok
  def create_users(count, params) do
    collection =
      1..count
      |> Enum.map(fn _n -> params end)
      |> Stream.chunk_every(1000)

    Task.Supervisor.async_stream_nolink(
      UsersScores.TaskSupervisor,
      collection,
      fn chunk -> Repo.insert_all(User, chunk) end,
      ordered: false
    )
    |> Stream.run()

    :ok
  end

  @spec update_users_points(integer, integer, pos_integer) :: :ok
  def update_users_points(first_id \\ 1, last_id \\ 1_000_000, chunk_every \\ 1000) do
    date_time_now = DateTime.utc_now()

    collection = first_id..last_id |> Stream.chunk_every(chunk_every)

    Task.Supervisor.async_stream_nolink(
      UsersScores.TaskSupervisor,
      collection,
      fn range ->
        min_id = List.first(range)
        max_id = List.last(range)

        User.Query.update_users_with_random_number(min_id, max_id, date_time_now)
        |> Repo.update_all([])
      end,
      ordered: false
    )
    |> Stream.run()

    :ok
  end
end
