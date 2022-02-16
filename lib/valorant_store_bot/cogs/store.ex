defmodule ValorantStoreBot.Cogs.Store do
  @behaviour Nosedrum.Command

  alias Nostrum.Api

  @impl true
  def usage, do: ["store"]

  @impl true
  def description, do: "自分のストアを確認できます"

  @impl true
  def predicates, do: []

  @impl true
  def command(msg, _args) do
    {:ok, _msg} = Api.create_message(msg.channel_id, "store not implemented")
  end
end
