defmodule UsersScores do
  @moduledoc """
  UsersScores keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def return_users do
    UsersScores.PointsUpdater.return_users() |> format_timestamp()
  end

  defp format_timestamp(%{timestamp: nil} = params), do: params

  defp format_timestamp(%{timestamp: timestamp} = params) do
    formatted_timestamp =
      timestamp
      |> DateTime.to_naive()
      |> NaiveDateTime.truncate(:second)
      |> NaiveDateTime.to_string()

    %{params | timestamp: formatted_timestamp}
  end
end
