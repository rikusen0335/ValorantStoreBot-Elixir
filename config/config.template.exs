import Config

config :nostrum,
  token: "YOUR BOT TOKEN"

config :nosedrum,
  prefix: System.get_env("BOT_PREFIX") || "."

config :tesla, adapter: Tesla.Adapter.Hackney
