defmodule ValorantStoreBot.Cogs.Login do
  @behaviour Nosedrum.Command

  alias Nostrum.Api

  @impl true
  def usage, do: ["login"]

  @impl true
  def description, do: "ストアの確認のためにValorantにログインします"

  @impl true
  def predicates, do: []

  @impl true
  def command(msg, _args) do
    {:ok, _msg} = Api.create_message(msg.channel_id, "login not implemented")
  end
end
