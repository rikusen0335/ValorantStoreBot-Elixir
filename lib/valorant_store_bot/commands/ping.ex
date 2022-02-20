defmodule ValorantStoreBot.Commands.Ping do
  @behaviour Nosedrum.ApplicationCommand
  alias ValorantStoreBot.Repo
  alias Nostrum.Api

  @impl true
  def description() do
    "Ping/Pong"
  end

  @impl true
  def command(interaction) do
    # Api.create_interaction_response(interaction, %{
    #   type: 4,
    #   data: %{
    #     content: "Pong!",
    #     flags: 64
    #   }
    # })
    [
      content: "Pong!",
      ephemeral?: true
    ]
  end

  # Reference: https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-types
  @impl true
  def type() do
    :slash
  end

  @impl true
  def options() do
    []
  end
end
