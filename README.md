# UsersScores

### How the application works

The app has one endpoint which returns user list (maximum 2) and timestamp of the previous request. Returned users must have `points` number higher than random minimal number stored in the application state.
There are 1_000_000 (one milion) users created while setting up the database.
Each minute, a background worker will run to update all users' `points` and change minimal number to a different random value.

### Running it locally

1. Copy the GitHub repo.
2. Navigate in terminal to `/users_scores` (project main) directory.
3. Make sure you have Elixir and Erlang installed. You can use [asdf ](https://asdf-vm.com/) to get the latest versions. You can also add `/tool-versions` file. Versions used during development:

- elixir 1.14.2
- erlang 25.1.1

4. Run `mix ecto.setup` which will create database, users table and populate it with one million users.
5. To run code analysis tools and tests, run `mix dialyzer`, `mix credo` and `mix test`.
6. Next run `mix phx.server`.
7. Open browser and enter http://localhost:4000/
8. The users' points should be updated in the background within a minute.

### How requirements were approached

- `mix ecto.setup will create a Users table with 4 columns, id, points and the usual 2 timestamps. `:

  - users schema created in [this commit](https://github.com/MichalWojcieszyk/users-scores/commit/4130710be8a7d1e1cda7e79668cc0bf059b0a503)
  - added additional alias for `mix ecto.setup` (which runs also seeds) from main project directory in [this commit](https://github.com/MichalWojcieszyk/users-scores/commit/6a5d41216f1c7d2efec077bc0f3fb4339a4025a0)
  - in seeds, `create_users` function will be called, defined in [this commit](https://github.com/MichalWojcieszyk/users-scores/commit/505bb8550007f9c092dcdc4c7978cb7d9418d99f)
  - function for creating users is defined in [this commit](https://github.com/MichalWojcieszyk/users-scores/commit/66f474d5f2b4207634d61a4ebf36ad44a0cf3d85). The biggest issue with creating users was their number. A better option to insert them is using `Repo.insert_all` instead of standard `Repo.insert`, to avoid one million separate DB requests. The issue with just inserting all of the users, even with `Repo.insert_all` was that Postgres can't handle that many parameters at once. Because of that users creation should be split into chunks. Code like this worked:

  ```
  # 0 as a score is a default value, so no need to add it to params, thanks to that we can have fewer chunks
  params = %{inserted_at: date_time_utc_now, updated_at: date_time_utc_now}
  postgres_parameters_limit = 65535
  chunk_size = Integer.floor_div(@postgres_parameters_limit, map_size(params))

  1..1_000_000
  |> Enum.map(fn _n -> params end)
  |> Enum.chunk_every(1000)
  |> Enum.each(&Repo.insert_all(User, &1))
  ```

  and probably it will be fine for this use case. It runs in ~9 seconds and the `seed` task is used very rarely, by developers not users, so probably further optimization shouldn't be necessary. Just for sake of this task, the implementation was changed to more performant one, using lazy enumerable `Stream` and supervised `Task`, thanks to that each chunk was processed in parallel.
  I also played a bit with chunk size and found out that for 1_000_000 users, 1000 as a chunk size is optimal (faster then maximum Postgres size chunk, lower values than 1000 have worse performance as there were too many tasks that hit the database).
  After the optimization, users creation takes ~5 seconds.

- `The app should start when you run without warnings (warnings in dependencies are okay) or errors using: mix phx.server`:
  - warnings as errors during compilation for backend and web apps added [here](https://github.com/MichalWojcieszyk/users-scores/commit/b1c1d635220209145dd8d086fde6369c90100632)
- `When the app starts, a genserver should be launched which will:`
  - added in [commit](https://github.com/MichalWojcieszyk/users-scores/commit/0c44a75b8a578150f8289d34a8035d447bed806c)
  - GenServer is started and supervised on app start
- `Run every minute and when it runs:`:
  - added in [commit](https://github.com/MichalWojcieszyk/users-scores/commit/0c44a75b8a578150f8289d34a8035d447bed806c)
  - running it each minute is handled using `Process.send_after(self(), :update, @one_minute)` code called in loop and handled in `handle_info` callback
- `Should update every user's points in the database (using a random number generator [0-100] for each)`:
  - similar to users creation, it's better to handle this by not calling database for each record update
  - when updating using `Repo.update_all` it was not possible to set random values in database using Elixir code, so it was done by calling Postgres function (`floor(random()*100)`)
  - optimization
    1. I started simple with `Repo.update_all` for all records at once and it took ~9 seconds, which seems to be a bit too long, taking into account it's going to run every minute
    2. Thanks to id being in order and not uuid and possibility to use `where` for `Repo.update_all`, it was possible to handle this update based on ids (after the potential creation of more users in database, it will require some modifications). Finally, the best results were achieved using a similar approach as for creation (`Stream`, `Task` and 1000 sized chunks). The final benchmark is ~2 seconds, which seems to be fine for this use case.
- `Should accept a handle_call that:`:
  - added in [commit](https://github.com/MichalWojcieszyk/users-scores/commit/0c44a75b8a578150f8289d34a8035d447bed806c)
  - `handle_call` callback queries the database and returns 2 users
  - because of the limit of users, query works really fast and it wasn't necessary to optimize it further
  - in the description there is nothing mentioned about unique results or specific results, so just `limit` option on query is used
- `Build a single endpoint, root`:
  - endpoint together with tests and updated routes added in [commit](https://github.com/MichalWojcieszyk/users-scores/commit/9fe0a2dd41f764064c40be95f2ce09c03632f960)
  - because there is only one endpoint and the returned JSON is very simple, it was just handled in controller, in general with more endpoints I will create separate `view` files
  - test for controller is written in a more integration way, handling three consecutive requests

### Approaches

- I try to follow the approach of starting with simple, working code and later making it nicer and (if necessary) more performant. Looking at benchmarks before and after, I think it was worth to improve updating users action performance, but probably a slower version of users creation in seeds will be also fine.
- I approached commits history in the same way as I do on daily basis with my PRs. I try to make them clean, easy and understandable for reviewers, so they can review them commit by commit and see how the app was changed in logical order. The commits were rebased couple times.

### Other and things worth mentioning

- Frontend part is simple for this app, even with apps this size I prefer to use umbrella app and separate frontend and backend (separation of concerns, ready to grow).
- Application has separate read and write sides using loaders and mutators approach. Even for app this small, I found it better to have these two sites separated.
- I found tests for `User.Query` not necessary, as these functions are well tested in other modules, although I don't have strong opinion here, they might be also added.
- For `create_users` function test was used real life value 1_000_000 which made it a bit slow, but I think it's worth doint that to check if there are not issues with number that big (and the whole test suite is still fast).
- `queue_target` value was increased to handle longer queries.
- `Ecto.Adapters.SQL.query(Repo, "ALTER SEQUENCE users_id_seq RESTART WITH 1")` was added to restart autogenerated ids counter to 1 before some tests (it was not done automatically)
- The first thing I will consider improving is GenServer testing strategy and configuration. I tried to simulate in tests real situation (GenServer is started and supervised on app start) although that leads to some issues (state was shared between tests). I handled this by adding an additional `handle_cast` for tests purposes, which reverts GenServer state to the initial one. Another possibility to approach tests might be starting GenServer separately for each test, which will keep the state isolated. I don't have a strong preference here, probably, the decision on choosing one of the options will depend on the next requirements for the application.
- All benchmarks were done on my local machine
