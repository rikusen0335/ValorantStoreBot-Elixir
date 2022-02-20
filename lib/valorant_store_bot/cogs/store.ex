defmodule ValorantStoreBot.Cogs.Store do
  @behaviour Nosedrum.Command
  alias ValorantStoreBot.Repo
  alias Nostrum.Api

  import Nostrum.Struct.Embed

  @impl true
  def usage, do: ["store"]

  @impl true
  def description, do: "自分のストアを確認できます"

  @impl true
  def predicates, do: []

  @impl true
  def command(msg, _args) do
    # Check we have user's account informations
    discord_user_id = Integer.to_string(msg.author.id)
    Repo.get_by(ValorantAuth, discord_user_id: discord_user_id)
    |> case do
      # if no, send message to user to login
      nil -> Api.create_message(msg.channel_id, "ログインを先に行ってください。(`/login`)\nまた、パスワードがこのボットの管理者にめちゃくちゃバレるので気をつけてください。")

      # if yes, retrive data from api
      %ValorantAuth{username: username, password: password} ->
        Api.create_message(msg.channel_id, ":hourglass: 情報を取得中です...")

        %{riot_token: token, riot_entitlement: entitlement} = RiotAuthUtils.login_and_retrive_token_entitlement(username, password)

        puuid = RiotAuthApi.client(token) |> RiotAuthApi.get_uuid()
        valorant_client = ValorantApi.client(token, entitlement)
        {:ok, response} = valorant_client |> ValorantApi.get_storefront(puuid)
        %{valorant_points: valop, radianite_points: radip} = ValorantApi.get_wallet(valorant_client, puuid)

        %{offerRemainingDurationInSeconds: remaining_seconds, skins: skins} = ValorantUtils.get_daily_storefront(response.body)

        %{player_name: player_name} = Repo.get_by(ValorantAuth, discord_user_id: Integer.to_string(msg.author.id))

        {h, m, s} = seconds_to_hours_minutes_seconds(remaining_seconds)
        remaining_time = "#{h}時間#{m}分#{s}秒"

        skins_with_cost = skins
        |> Enum.map(fn skin ->
          %Offer{cost: cost} = valorant_client |> ValorantApi.find_offer_by_uuid(skin.uuid)

          %ImageGenerator.SkinInfo{name: skin.display_name, imageUrl: skin.display_icon, cost: cost}
        end)

        daily_store_image = ImageGeneratorApi.client() |> ImageGeneratorApi.generate_daily_store(skins_with_cost)
        |> case do
          {:ok, response} ->
            # IO.inspect(response)
            response.body
          {:error, error} -> IO.inspect(error)
        end

        # and return data using embed to display
        main_embed = %Nostrum.Struct.Embed{}
        |> put_description(":mag: #{player_name} | **今日のストア** | 残り時間: #{remaining_time}")
        |> put_field("Valorantポイント", valop)
        |> put_field("レディアナイトポイント", radip)
        # |> put_image(daily_store_image)
        |> put_color(431_948)
        case daily_store_image do
          :timeout -> Api.create_message(msg.channel_id,
            content: ":x: 結果を取得できませんでした。もう一度お試しください。",
            message_reference: %{message_id: msg.id}
          )
          _ -> Api.create_message(msg.channel_id,
            embed: main_embed,
            message_reference: %{message_id: msg.id},
            file: %{name: "daily_store.png", body: daily_store_image}
          )
        end
    end
  end

  def seconds_to_hours_minutes_seconds(seconds) do
    { div(seconds, 3600), rem(seconds, 3600) |> div(60),  rem(seconds, 3600) |> rem(60)}
  end
end
