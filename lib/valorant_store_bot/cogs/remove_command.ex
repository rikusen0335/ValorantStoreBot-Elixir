defmodule ValorantStoreBot.Cogs.RemoveCommand do
  @behaviour Nosedrum.Command

  alias Nostrum.Api

  @impl true
  def usage, do: ["removecmd"]

  @impl true
  def description, do: "アプリケーションコマンドをサーバーから削除する"

  @impl true
  def predicates, do: []

  @impl true
  def command(msg, _args) do
    # Nosedrum.Interactor.Dispatcher.add_command("echo", ValorantStoreBot.Commands.Echo, msg.guild_id)
    case Nosedrum.Interactor.Dispatcher.remove_command("login", ValorantStoreBot.Commands.Login, msg.guild_id) do
      {:ok, _} ->
        Api.create_message(msg.channel_id, "アプリケーションコマンドを**削除**しました")
        IO.puts("Registered Login command.")
      e ->
        Api.create_message(msg.channel_id, "なんらかの理由によりアプリケーションコマンドを削除できませんでした")
        IO.inspect(e, label: "An error occurred removing the Login command")
    end

    case Nosedrum.Interactor.Dispatcher.remove_command("logout", ValorantStoreBot.Commands.Logout, msg.guild_id) do
      {:ok, _} -> IO.puts("Removed Logout command.")
      e -> IO.inspect(e, label: "An error occurred removing the Logout command")
    end

    case Nosedrum.Interactor.Dispatcher.remove_command("store", ValorantStoreBot.Commands.Store, msg.guild_id) do
      {:ok, _} -> IO.puts("Removed Store command.")
      e -> IO.inspect(e, label: "An error occurred removing the Store command")
    end

    case Nosedrum.Interactor.Dispatcher.remove_command("ping", ValorantStoreBot.Commands.Ping, msg.guild_id) do
      {:ok, _} -> IO.puts("Removed Ping command.")
      e -> IO.inspect(e, label: "An error occurred removing the Ping command")
    end
  end
end
