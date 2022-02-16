defmodule RiotAuthApi do

  @doc """
  Establish cookie-based session
  Cookieベースのセッションを準備する
  """
  def auth_cookies(client) do
    req_body = %{
      client_id: "play-valorant-web-prod",
      nonce: 1,
      redirect_uri: "https://playvalorant.com/opt_in",
      response_type: "token id_token",
    }

    Tesla.post(client, "/api/v1/authorization", req_body, headers: [{"Content-Type", "application/json"}])
  end

  @doc """
  To use to login user
  ログインするときに使う
  """
  def auth_request(client, username, password) do
    req_body = %{
      type: "auth",
      username: username,
      password: password,
      remember: true,
      language: "ja_JP", # This should be able to change through config
    }

    Tesla.put(client, "/api/v1/authorization", req_body, headers: [{"Content-Type", "application/json"}])
  end

  @doc """
  To re-authenticate cookie, and you don't need token or something else
  Cookieを再認証するときに使う、トークンなどのものは必要ない
  """
  def reauth_cookie(client) do
    Tesla.get(client, "/authorize?redirect_uri=https%3A%2F%2Fplayvalorant.com%2Fopt_in&client_id=play-valorant-web-prod&response_type=token%20id_token&nonce=1")
  end

  @doc """
  Get current player's uuid
  現在ログインしているプレイヤーのuuidを取得する
  """
  @spec get_uuid(Tesla.Client.t()) :: String.t()
  def get_uuid(client) do
    Tesla.get(client, "/userinfo")

    "Not implemented"
  end

  @spec client(String.t()) :: Tesla.Client.t()
  def client(riot_token) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://auth.riotgames.com"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BearerAuth, token: riot_token}
    ]

    Tesla.client(middleware)
  end
end
