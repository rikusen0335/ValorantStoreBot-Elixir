import Config

config :nostrum,
  token: "YOUR BOT TOKEN"

config :nosedrum,
  prefix: System.get_env("BOT_PREFIX") || "."

config :tesla, adapter: Tesla.Adapter.Hackney

config :valorant_store_bot,
  ecto_repos: [ValorantStoreBot.Repo]

config :valorant_store_bot, ValorantStoreBot.Repo,
  database: "./database.db" # Change anything you want

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase
