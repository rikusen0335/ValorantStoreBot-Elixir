defmodule OtherUtils do
  alias ValorantStoreBot.Repo

  alias Nostrum.Api
  alias Nostrum.Struct.Interaction

  @spec check_auth_data(Interaction.t()) :: {:ok} | {:error, String.t()}
  def check_auth_data(interaction) do
    discord_user_id = DiscordUtils.get_user_id(interaction)

    Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)
    |> case do
      nil ->
        Api.create_interaction_response(interaction, %{
          type: 4,
          data: %{
            content: "ログインを先に行ってください。(`/login`)\nまた、パスワードがこのボットの管理者にめちゃくちゃバレるので気をつけてください。\n\nパスワード生成ツールなどを使用して生成したパスワードを使用することをおすすめします。メモするのを忘れないでください。",
            flags: 64
          }
        })
        {:error, "認証情報がありません"}
      _ ->
        {:ok}
    end
  end
end
