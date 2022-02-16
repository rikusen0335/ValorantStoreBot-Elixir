defmodule Valorant do
  @doc """
  Show current store offer for user
  現在のストアの情報を表示する
  """
  @spec get_storefront(Tesla.Client.t(), String.t()) :: Tesla.Env.result()
  def get_storefront(client, player_uuid) do
    Tesla.get(client, "/store/v2/storefront/" <> player_uuid)
  end

  @spec client(String.t(), String.t()) :: Tesla.Client.t()
  def client(riot_token, riot_entitlement) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://pd.ap.a.pvp.net"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [
        {"X-Riot-Entitlements-JWT", riot_entitlement}
      ]},
      {Tesla.Middleware.BearerAuth, token: riot_token}
    ]

    Tesla.client(middleware)
  end
end
