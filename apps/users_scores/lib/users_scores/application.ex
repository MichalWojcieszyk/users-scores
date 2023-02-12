defmodule UsersScores.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      UsersScores.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: UsersScores.PubSub}
      # Start a worker by calling: UsersScores.Worker.start_link(arg)
      # {UsersScores.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: UsersScores.Supervisor)
  end
end
