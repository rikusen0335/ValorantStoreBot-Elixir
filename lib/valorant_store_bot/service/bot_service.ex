defmodule Service.BotService do
  alias Nostrum.Api

  alias ValorantStoreBot.Repo
  alias ValorantStoreBot.Struct.State.AuthState

  import Nostrum.Struct.Embed

  def request_daily_store(interaction) do
    discord_user_id = DiscordUtils.get_user_id(interaction)

    OtherUtils.check_auth_data(interaction)
    |> case do
      {:error, _} -> :noop
      {:ok} ->
        %{username: username, password: password} = Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)

        discord_user_id = DiscordUtils.get_user_id(interaction)
        auth_client = RiotAuthApi.client("")
        initial_cookie = auth_client |> RiotAuthApi.auth_cookies()

        # Thus auth_request returns token with path, or 2fa response
        # auth_requestは成功時にパスに入ったトークンか、もしくは2段階認証を返す
        %{body: res_body, cookie: mfa_cookie} = auth_client |> RiotAuthApi.auth_request(initial_cookie, username, password)

        case res_body do
          # When 2fa
          %{"type" => "multifactor"} ->
            Memento.transaction! fn ->
              Memento.Query.select(AuthState, {:==, :discord_user_id, discord_user_id})
              |> Enum.at(0)
              |> case do
                struct when struct != nil -> Memento.Query.write(%AuthState{id: struct.id, discord_user_id: discord_user_id, state_name: "2fa", executed_command: "store", cookie: mfa_cookie})
              end
            end

            Api.create_interaction_response(interaction, %{
              type: 9,
              data: %{
                custom_id: "2fa_code_modal",
                title: "2段階認証",
                components: [%{
                  type: 1,
                  components: [
                    %{
                      type: 4,
                      custom_id: "2fa_code",
                      label: "認証コードを入力",
                      style: 1,
                      min_length: 6,
                      max_length: 6,
                      placeholder: "000000",
                      required: true
                    }
                  ]
                }]
              }
            })

          # When normal
          %{"type" => "response"} = res_body ->
            %{riot_token: token, riot_entitlement: entitlement} = RiotAuthUtils.retrive_token_and_entitlement(res_body)
            %{offer_remaining_duration: remaining_time, skins_with_cost: skins_with_cost} = ValorantUtils.get_daily_store(token, entitlement)

            puuid = RiotAuthApi.client(token) |> RiotAuthApi.get_uuid()

            valorant_client = ValorantApi.client(token, entitlement)
            %{valorant_points: valop, radianite_points: radip} = ValorantApi.get_wallet(valorant_client, puuid)

            %{player_name: player_name} = Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)

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
        end
    end
  end

  def request_night_market(interaction) do
    # Not implemented
  end

  def login(interaction) do
    [%{name: "username", value: username}, %{name: "password", value: password}] = interaction.data.options

    discord_user_id = DiscordUtils.get_user_id(interaction)

    Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)
    |> case do
      nil ->
        auth_client = RiotAuthApi.client("")
        initial_cookie = auth_client |> RiotAuthApi.auth_cookies()

        # Thus auth_request returns token with path, or 2fa response
        # auth_requestは成功時にパスに入ったトークンか、もしくは2段階認証を返す
        %{body: res_body, cookie: mfa_cookie} = auth_client |> RiotAuthApi.auth_request(initial_cookie, username, password)

        case res_body do
          # When 2fa
          %{"type" => "multifactor"} ->
            Memento.transaction! fn ->
              Memento.Query.select(AuthState, {:==, :discord_user_id, discord_user_id})
              |> Enum.at(0)
              |> case do
                struct when struct != nil ->
                  Memento.Query.write(%AuthState{
                    id: struct.id,
                    discord_user_id: discord_user_id,
                    state_name: "2fa",
                    executed_command: "login",
                    cookie: mfa_cookie,
                    username: struct.username,
                    password: struct.password
                  })
              end
            end

            Api.create_interaction_response(interaction, %{
              type: 9,
              data: %{
                custom_id: "2fa_code_modal",
                title: "2段階認証",
                components: [%{
                  type: 1,
                  components: [
                    %{
                      type: 4,
                      custom_id: "2fa_code",
                      label: "認証コードを入力",
                      style: 1,
                      min_length: 6,
                      max_length: 6,
                      placeholder: "000000",
                      required: true
                    }
                  ]
                }]
              }
            })

          # When normal
          %{"type" => "response"} = res_body ->
            %{riot_token: token, riot_entitlement: entitlement} = RiotAuthUtils.retrive_token_and_entitlement(res_body)
            puuid = RiotAuthApi.client(token) |> RiotAuthApi.get_uuid()

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
        end
      _ ->
        Api.create_interaction_response(interaction, %{
          type: 4,
          data: %{
            content: "すでにログインしています。ログアウトする場合は/logoutを使用してください",
            flags: 64
          }
        })
    end
  end

  def logout(interaction) do
    discord_user_id = DiscordUtils.get_user_id(interaction)
    Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)
    |> case do
      nil ->
        Api.create_interaction_response(interaction, %{
          type: 4,
          data: %{
            content: "ログインしていないときはログアウトできません",
            flags: 64
          }
        })
      struct ->
        Repo.delete(struct)
        |> case do
          {:ok, struct} ->
            IO.inspect(struct)
            Api.create_interaction_response(interaction, %{
              type: 4,
              data: %{
                content: "正常にログアウトできました",
                flags: 64
              }
            })
          {:error, changeset} ->
            IO.inspect(changeset)
            Api.create_interaction_response(interaction, %{
              type: 4,
              data: %{
                content: "ログアウトできませんでした。もう一度お試しください",
                flags: 64
              }
            })
      end
    end
  end
end
