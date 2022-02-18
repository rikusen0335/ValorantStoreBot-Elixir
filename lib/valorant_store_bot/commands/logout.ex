defmodule ValorantStoreBot.Commands.Logout do
  @behaviour Nosedrum.ApplicationCommand
  alias ValorantStoreBot.Repo

  @impl true
  def description() do
    "ログアウトをするコマンド"
  end

  @impl true
  def command(interaction) do
    userid = Integer.to_string(interaction.member.user.id)
    Repo.get_by!(ValorantAuth, discord_user_id: userid)
    |> Repo.delete()
    |> case do
      {:ok, struct} ->
        IO.inspect(struct)
        [
          content: "正常にログアウトできました",
          ephemeral?: true
        ]
      {:error, changeset} ->
        IO.inspect(changeset)
        [
          content: "ログアウトできませんでした。もう一度お試しください",
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
