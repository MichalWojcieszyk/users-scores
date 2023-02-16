defmodule UsersScores.User.Helpers do
  def timestamp_utc_now, do: DateTime.truncate(DateTime.utc_now(), :second)
end
