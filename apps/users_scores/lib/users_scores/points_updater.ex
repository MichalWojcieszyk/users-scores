defmodule UsersScores.PointsUpdater do
  use GenServer

  alias UsersScores.User

  @users_limit 2
  @one_minute 60_000

  def start_link(init_params) do
    GenServer.start_link(__MODULE__, init_params, name: PointsState)
  end

  def return_users do
    GenServer.call(PointsState, :return)
  end

  @impl true
  def init(init_params) do
    schedule_next_update()

    {:ok, init_params}
  end

  @impl true
  def handle_call(:return, _from, previous_state) do
    users = User.Loader.with_more_points(previous_state.min_number, @users_limit)
    new_timestamp = DateTime.utc_now()

    {:reply, %{users: users, timestamp: previous_state.timestamp},
     %{min_number: previous_state.min_number, timestamp: new_timestamp}}
  end

  @impl true
  def handle_info(:update, state) do
    UsersScores.User.Mutator.update_users_points()
    schedule_next_update()

    {:noreply, %{min_number: Enum.random(0..100), timestamp: state.timestamp}}
  end

  defp schedule_next_update do
    Process.send_after(self(), :update, @one_minute)
  end
end
