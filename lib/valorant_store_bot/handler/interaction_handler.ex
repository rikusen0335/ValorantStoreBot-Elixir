defmodule Handler.Interaction do
  alias Nostrum.Api
  alias Nostrum.Struct.Interaction

  alias ValorantStoreBot.Repo
  alias Schema.CookieSession

  @spec handle(%Interaction{}) :: {:ok} | {:error, String.t()}
  def handle(interaction) do
    execute(interaction)
  end

  @doc """
  Get a 2fa code from the modal
  モーダルから送られてきた2段階認証のコードを取得する
  """
  defp execute(%Interaction{data: %{components: [%{components: [%{custom_id: "2fa_code", type: 4, value: code}], type: 1}]}} = interaction) do
    discord_user_id = DiscordUtils.get_user_id(interaction)
    Repo.get_by(CookieSession, discord_user_id: discord_user_id)
    |> case do
      nil ->
        IO.puts("Failed to get cookie from db.")
        Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)
        |> Repo.delete()
        |> case do
          {:ok, struct} -> IO.inspect(struct, label: "Successfully deleted Valorant auth data")
          {:error, changeset} -> IO.inspect(changeset, label: "Failed to delete the Valorant auth. Is the data exist?")
        end
      %CookieSession{cookie: cookie} ->
        RiotAuthApi.client("") |> RiotAuthApi.send_2fa_code(cookie, code)
        |> case do
          {:ok, response} ->
            # IO.inspect(response, label: "Got response from 2fa")
            %{riot_token: token, riot_entitlement: entitlement} = RiotAuthUtils.retrive_token_and_entitlement(response.body)

            Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)
            |> case do
              nil ->
                IO.puts("Couldn't get auth data from the discord user id: #{discord_user_id}")
              struct ->
                puuid = RiotAuthApi.client(token) |> RiotAuthApi.get_uuid()
                %{game_name: game_name, tagline: tagline} = ValorantApi.client(token, entitlement) |> ValorantApi.get_ingame_name(puuid)
                Ecto.Changeset.change(struct, player_name: "#{game_name}##{tagline}")
                |> Repo.update()
                |> case do
                  {:ok, struct} -> IO.inspect(struct, label: "Successfully updated Valorant auth data")
                  {:error, changeset} -> IO.inspect(changeset, label: "Failed to updatte the Valorant auth data")
                end
            end
          {:error, error} -> IO.inspect(error)
        end
    end

    %ValorantAuth{player_name: player_name} = Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)
    |> case do
      nil -> IO.puts("What the hell is going on here???")
      struct -> struct
    end

    Api.create_interaction_response(interaction, %{
      type: 4,
      data: %{
        content: "#{player_name}として正常にログインできました",
        flags: 64
      }
    })

    {:ok}
  end

  # defp execute(%{Interaction{data: %{components: [%{components: [%{}]}]}}}) do

  # end

  defp execute(_) do
    # {:ok}
    {:error, "The interaction is not available in this handler"}
  end
end
