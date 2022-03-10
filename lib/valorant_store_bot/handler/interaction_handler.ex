defmodule Handler.Interaction do
  alias Nostrum.Api
  alias Nostrum.Struct.Interaction

  alias ValorantStoreBot.Repo
  alias ValorantStoreBot.Struct.State.AuthState
  alias Schema.CookieSession
  alias Service.BotService

  import Nostrum.Struct.Embed

  @spec handle(%Interaction{}) :: {:ok} | {:error, String.t()}
  def handle(interaction) do
    execute(interaction)
  end

  @doc """
  When application command
  Application commandの時
  """
  defp execute(%Interaction{type: 2} = interaction) do
    # IO.inspect(interaction)
    # IO.puts(interaction.data.name)

    discord_user_id = DiscordUtils.get_user_id(interaction)

    case interaction.data.name do
      #
      # ---------- Daily Store
      #
      "store" ->
        Memento.transaction! fn ->
          Memento.Query.write(%AuthState{discord_user_id: discord_user_id, state_name: "auth", executed_command: "store"})
        end

        interaction
        |> BotService.request_daily_store()
        {:ok}

      #
      # ---------- Nightmarket
      #
      "nightmarket" ->
        Memento.transaction! fn ->
          Memento.Query.write(%AuthState{discord_user_id: discord_user_id, state_name: "auth", executed_command: "nightmarket"})
        end

        interaction
        |> BotService.request_night_market()
        {:ok}

      #
      # ---------- Login
      #
      "login" ->
        [%{name: "username", value: username}, %{name: "password", value: password}] = interaction.data.options

        Memento.transaction! fn ->
          Memento.Query.write(%AuthState{
            discord_user_id: discord_user_id,
            state_name: "auth",
            executed_command: "login",
            username: username,
            password: password
          })
        end

        interaction
        |> BotService.login()
        {:ok}

      #
      # ---------- Logout
      #
      "logout" ->
        interaction
        |> BotService.logout()
        {:ok}

      cmd_name -> {:error, "Cannot handle this command (`#{cmd_name}`) with this handler"}
    end
  end

  @doc """
  Get a 2fa code from the modal
  モーダルから送られてきた2段階認証のコードを取得する
  """
  defp execute(%Interaction{data: %{components: [%{components: [%{custom_id: "2fa_code", type: 4, value: code}], type: 1}]}} = interaction) do
    # IO.puts(code)
    discord_user_id = DiscordUtils.get_user_id(interaction)
    Memento.transaction! fn ->
      result = Memento.Query.select(AuthState, {:==, :discord_user_id, discord_user_id})
      result
      |> Enum.at(0)
      |> case do
        %AuthState{state_name: "2fa", cookie: cookie, username: username, password: password} ->
          res_body = RiotAuthApi.client("") |> RiotAuthApi.send_2fa_code(cookie, code)

          # IO.inspect(response, label: "Got response from 2fa")
          %{riot_token: token, riot_entitlement: entitlement} = RiotAuthUtils.retrive_token_and_entitlement(res_body)

          case token do
            nil -> Api.create_interaction_response(interaction, %{
              type: 4,
              data: %{
                content: "2段階認証コードが間違っている可能性があります。もう一度お試しください",
                flags: 64
              }
            })
          end

          %{offer_remaining_duration: remaining_time, skins_with_cost: skins_with_cost} = ValorantUtils.get_daily_store(token, entitlement)

          puuid = RiotAuthApi.client(token) |> RiotAuthApi.get_uuid()

          valorant_client = ValorantApi.client(token, entitlement)
          %{valorant_points: valop, radianite_points: radip} = ValorantApi.get_wallet(valorant_client, puuid)

          # Avoidance for crash the program if not player_name is in db
          player_name = Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)
          |> case do
            %{player_name: p_name} -> p_name
            _ -> nil
          end

          # To remove modal, we need to ping to confirm we received the code (?)
          Api.create_interaction_response(interaction, %{type: 1})

          Enum.at(result, 0).executed_command
          |> case do
            #
            # ---------- Initial Login
            #
            "login" ->
              case entitlement do
                nil ->
                  Api.create_interaction_response(interaction, %{
                    type: 4,
                    data: %{
                      content: "ログイン情報が間違っている可能性があります",
                      flags: 64
                    }
                  })
                _ ->
                  %{game_name: game_name, tagline: tagline} = ValorantApi.client(token, entitlement) |> ValorantApi.get_ingame_name(puuid)

                  Repo.insert(%ValorantAuth{
                    discord_user_id: discord_user_id,
                    username: username,
                    password: password,
                    player_name: "#{game_name}##{tagline}",
                  })

                  Memento.transaction! fn ->
                    Memento.Query.select(AuthState, {:==, :discord_user_id, discord_user_id})
                    |> Enum.at(0)
                    |> case do
                      struct when struct != nil -> Memento.Query.delete_record(struct)
                    end
                  end

                  Api.create_interaction_response(interaction, %{
                    type: 4,
                    data: %{
                      content: "#{game_name}##{tagline}として正常にログインできました",
                      flags: 64
                    }
                  })
              end

            #
            # ---------- Daily Store
            #
            "store" ->
              Api.create_interaction_response(interaction, %{
                type: 4,
                data: %{
                  content: ":hourglass: 結果を取得中です...",
                  flags: 64
                }
              })

              daily_store_image = ImageGeneratorApi.client() |> ImageGeneratorApi.generate_daily_store(skins_with_cost)
              |> case do
                {:ok, response} ->
                  # IO.inspect(response)
                  response.body
                {:error, error} -> IO.inspect(error)
              end

              # Remove unnecessary state record
              Memento.transaction! fn ->
                Memento.Query.select(AuthState, {:==, :discord_user_id, discord_user_id})
                |> Enum.at(0)
                |> case do
                  struct when struct != nil -> Memento.Query.delete_record(struct)
                end
              end

              main_embed = %Nostrum.Struct.Embed{}
              |> put_description(":mag: #{player_name} | **今日のストア** | 残り時間: #{remaining_time}")
              |> put_field("Valorantポイント", valop)
              |> put_field("レディアナイトポイント", radip)
              # |> put_image(daily_store_image)
              |> put_color(431_948)
              case daily_store_image do
                :timeout -> Api.create_message(interaction.channel_id,
                  content: ":x: 結果を取得できませんでした。もう一度お試しください。"
                )
                _ -> Api.create_message(interaction.channel_id,
                  embed: main_embed,
                  file: %{name: "daily_store.png", body: daily_store_image}
                )
              end

            #
            # ---------- Nightmarket
            #
            "nightmarket" ->
              Api.create_interaction_response(interaction, %{
                type: 4,
                data: %{
                  content: "#{player_name}として正常にログインできました",
                  flags: 64
                }
              })

            _ -> Api.create_interaction_response(interaction, %{
              type: 4,
              data: %{
                content: "aaa",
                flags: 64
              }
            })
          end

        state -> IO.inspect(state)
      end
    end
    {:ok}
  end

  # defp execute(%{Interaction{data: %{components: [%{components: [%{}]}]}}}) do

  # end

  defp execute(_) do
    # {:ok}
    {:error, "The interaction is not available in this handler"}
  end
end
