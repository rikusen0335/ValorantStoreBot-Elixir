defmodule ValorantUtils do

  @doc """
  Retrive daily storefront data from ValorantApi.get_storefront
  毎日更新されるストアの情報をValorantApi.get_storefrontから取得する
  """
  @spec get_daily_storefront(Tesla.Env.body()) :: %{ offerRemainingDurationInSeconds: integer(), skins: list(%Weapon.SkinLevel{}) }
  def get_daily_storefront(body) do
    client = ValorantThirdpartyApi.client()

    # Array
    raw_weapon_skins = body["SkinsPanelLayout"]["SingleItemOffers"]
    weapon_skins = Enum.map(
      raw_weapon_skins,
      fn w_id ->
        raw = ValorantThirdpartyApi.get_weapon_skin_by_uuid(client, w_id)
        serialize_weapon_skin_level(raw["data"])
      end)

    %{
      offerRemainingDurationInSeconds: body["SkinsPanelLayout"]["SingleItemOffersRemainingDurationInSeconds"],
      skins: weapon_skins,
    }
  end

  def retrive_weapon_skin_level(response) do
    case response do
      {:error, _} -> :noop
      {:ok, data} -> serialize_weapon_skin_level(data.body["data"])
    end
  end

  def serialize_weapon_skin_level(raw_weapon_skin_level) do
    %Weapon.SkinLevel{
      uuid: raw_weapon_skin_level["uuid"],
      display_name: raw_weapon_skin_level["displayName"],
      level_item: raw_weapon_skin_level["levelItem"],
      display_icon: raw_weapon_skin_level["displayIcon"],
      streamed_video: raw_weapon_skin_level["streamedVideo"],
      asset_path: raw_weapon_skin_level["assetPath"],
    }
  end

  @doc """
  Cache the retrival of ValorantApi.get_all_offers data
  ValorantApi.get_all_offersで取得したデータをキャッシュとして保存する
  """
  def update_cache_offers(offers) do
    File.write("./offers_cache.json", Jason.encode!(offers), [:binary])
  end

  def get_all_cached_offers do
    with {:ok, body} <- File.read("./offers_cache.json"),
         {:ok, json} <- Jason.decode(body), do: {:ok, json}
  end
end
