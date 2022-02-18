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
    auth_client = RiotAuthApi.client("")
    cookie = auth_client |> RiotAuthApi.auth_cookies()
    {:ok, riot_token_path} = auth_client |> RiotAuthApi.auth_request(cookie, username, password)

    token_client = riot_token_path |> RiotAuthApi.get_riot_access_token() |> RiotTokenApi.client()
    riot_entitlement = token_client |> RiotTokenApi.get_riot_entitlement()

    if riot_entitlement == nil do # DMに変える
      Api.create_message(msg.channel_id, "ログイン情報が間違っている可能性があります。")
    else
      Api.create_message(msg.channel_id, "正常にログインできました。")
      Repo.insert(%ValorantAuth{discord_user_id: Integer.to_string(msg.author.id), username: username, password: password, })
    end
  end
end
