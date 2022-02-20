defmodule ValorantStoreBot.Commands.Login do
  @behaviour Nosedrum.ApplicationCommand

  alias Nostrum.Api
  alias ValorantStoreBot.Repo

  use GenServer

  @impl true
  def description() do
    "ログインをするコマンド"
  end

  @impl true
  def command(interaction) do
    [%{name: "username", value: username}, %{name: "password", value: password}] = interaction.data.options

    discord_user_id = DiscordUtils.get_user_id(interaction)
    Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)
    |> case do
      nil -> RiotAuthUtils.request_login(interaction, username, password)
      %ValorantAuth{player_name: player_name} ->
        case player_name do
          nil -> RiotAuthUtils.request_login(interaction, username, password)
          _ ->
            [
              content: "すでにログインしています。ログアウトする場合は/logoutを使用してください。",
              ephemeral?: true
            ]
        end
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
