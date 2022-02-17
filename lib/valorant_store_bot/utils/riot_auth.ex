defmodule RiotAuthUtils do
  # @spec login_and_retrive_token_entitlement(String.t(), String.t()) :: %{String.t(), String.t()}
  def login_and_retrive_token_entitlement(username, password) do
    auth_client = RiotAuthApi.client("")
    cookie = auth_client |> RiotAuthApi.auth_cookies()
    {:ok, riot_token_path} = auth_client |> RiotAuthApi.auth_request(cookie, username, password)

    riot_token = riot_token_path |> RiotAuthApi.get_riot_access_token()
    token_client = riot_token |> RiotTokenApi.client()
    riot_entitlement = token_client |> RiotTokenApi.get_riot_entitlement()

    %{
      riot_token: riot_token,
      riot_entitlement: riot_entitlement,
    }
  end
end
