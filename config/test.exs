import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :users_scores, UsersScores.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "users_scores_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  queue_target: 3000

config :users_scores, init_min_number: 40

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :users_scores_web, UsersScoresWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "RzQ3IvbcHtoRdacuggsUqM8IBYP3Sivcc2KbSNRfIbJPZPDFeBg9ipRTwgare3xp",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
