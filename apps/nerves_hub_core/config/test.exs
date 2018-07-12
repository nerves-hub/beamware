use Mix.Config

config :nerves_hub_core, NervesHubCore.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: false,
  database: "nerves_hub_test",
  pool: Ecto.Adapters.SQL.Sandbox
