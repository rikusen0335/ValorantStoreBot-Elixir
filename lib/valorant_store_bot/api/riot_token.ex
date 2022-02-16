defmodule RiotTokenApi do
  @doc """
  Get token to use Valorant API
  Valorant APIで使うトークンを取得する
  """
  def get_entitlement_token do
    Tesla.post("/api/token/v1", headers: [{"content-type", "application/json"}])
  end

  @spec client(String.t()) :: Tesla.Client.t()
  def client(riot_token) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://entitlements.auth.riotgames.com"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BearerAuth, token: riot_token}
    ]

    Tesla.client(middleware)
  end
end
