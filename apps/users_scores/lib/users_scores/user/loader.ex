defmodule UsersScores.User.Loader do
  alias UsersScores.{Repo, User}

  @spec with_more_points(integer(), integer()) :: list(User.t())
  def with_more_points(min_points, count) do
    min_points |> User.Query.with_more_points(count) |> Repo.all()
  end
end
