defmodule ValorantStoreBot.Cogs.ApplyCommand do
  @behaviour Nosedrum.Command

  alias Nostrum.Api

  @impl true
  def usage, do: ["applycmd"]

  @impl true
  def description, do: "アプリケーションコマンドをサーバーに適用する"

  @impl true
  def predicates, do: []

  @impl true
  def command(msg, _args) do
    # Nosedrum.Interactor.Dispatcher.add_command("echo", ValorantStoreBot.Commands.Echo, msg.guild_id)
    case Nosedrum.Interactor.Dispatcher.add_command("login", ValorantStoreBot.Commands.Login, msg.guild_id) do
      {:ok, _} -> Api.create_message(msg.channel_id, "アプリケーションコマンドを適用しました")
      e ->
        Api.create_message(msg.channel_id, "なんらかの理由によりアプリケーションコマンドを適用できませんでした")
        IO.inspect(e, label: "An error occurred registering the Login command")
    end
  end
end
