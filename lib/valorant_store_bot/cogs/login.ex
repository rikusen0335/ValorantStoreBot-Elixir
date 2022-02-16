defmodule ValorantStoreBot.Cogs.Login do
  @behaviour Nosedrum.Command

  alias Nostrum.Api
  alias ValorantStoreBot.Repo

  @impl true
  def usage, do: ["login <username> <password>"]

  @impl true
  def description, do: "ストアの確認のためにValorantにログインします"

  @impl true
  def predicates, do: []

  @impl true
  def command(msg, "") do
    {:ok, _msg} = Api.create_message(msg.channel_id, "login not implemented")
  end

  def command(msg, [_username]) do
    {:ok, _msg} = Api.create_message(msg.channel_id, "Send password")
  end

  def command(msg, [username, password]) do
    # ログインテスト処理
    {:ok, _msg} = Repo.insert(%ValorantAuth{discord_user_id: Integer.to_string(msg.author.id), username: username, password: password})
  end
end
