## Bootstrap and run

Duplicate `config/config.template.exs` and rename it to `config/config.exs`,
then change `YOUR BOT TOKEN` to your bot token

```
mix deps.get
mix run --no-halt

# OR if you want to debug the bot do this:

iex -S mix run --no-halt
```
