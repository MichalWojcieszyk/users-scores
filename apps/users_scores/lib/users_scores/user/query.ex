defmodule UsersScores.User.Query do
  import Ecto.Query, only: [from: 2]

  alias UsersScores.User

  def with_more_points(min_points, count) do
    from(u in User,
      where: u.points > ^min_points,
      limit: ^count,
      select: %{id: u.id, points: u.points}
    )
  end

  def update_users_with_random_number(min_id, max_id, timestamp) do
    from(u in User,
      where: u.id >= ^min_id,
      where: u.id <= ^max_id,
      update: [set: [points: fragment("floor(random()*100)"), updated_at: ^timestamp]]
    )
  end
end
