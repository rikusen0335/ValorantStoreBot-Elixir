defmodule ValorantStoreBot.Commands.Login do
  @behaviour Nosedrum.ApplicationCommand
  alias ValorantStoreBot.Repo

  @impl true
  def description() do
    "ログインをするコマンド"
  end

  @impl true
  def command(interaction) do
    [%{name: "username", value: username}, %{name: "password", value: password}] = interaction.data.options

    auth_client = RiotAuthApi.client("")
    cookie = auth_client |> RiotAuthApi.auth_cookies()
    {:ok, riot_token_path} = auth_client |> RiotAuthApi.auth_request(cookie, username, password)

    riot_token = riot_token_path |> RiotAuthApi.get_riot_access_token()
    token_client = riot_token |> RiotTokenApi.client()
    puuid = RiotAuthApi.client(riot_token) |> RiotAuthApi.get_uuid()
    riot_entitlement = token_client |> RiotTokenApi.get_riot_entitlement()

    # IO.puts(riot_entitlement)

    case riot_entitlement do
      nil ->
        [
          content: "ログイン情報が間違っている可能性があります",
          ephemeral?: true
        ]
      _ ->
        %{game_name: game_name, tagline: tagline} = ValorantApi.client(riot_token, riot_entitlement) |> ValorantApi.get_ingame_name(puuid)
        Repo.insert(%ValorantAuth{
          discord_user_id: Integer.to_string(interaction.member.user.id),
          username: username,
          password: password,
          player_name: "#{game_name}##{tagline}",
        })
        [
          content: "#{game_name}##{tagline}として正常にログインできました",
          ephemeral?: true
        ]
    end
  end

  # Reference: https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-types
  @impl true
  def type() do
    :slash
  end

  @impl true
  def options() do
    [
      %{
        type: :string,
        name: "username",
        description: "RiotアカウントのID(Vandal#11111形式じゃないただのID)",
        required: true
      },
      %{
        type: :string,
        name: "password",
        description: "Riotアカウントのパスワード",
        required: true
      },
    ]
  end
end
