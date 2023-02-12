defmodule UsersScores.User do
  use Ecto.Schema

  @type t :: %__MODULE__{
          id: integer(),
          points: integer()
        }

  @timestamps_opts [type: :utc_datetime]
  schema "users" do
    field :points, :integer

    timestamps()
  end
end
