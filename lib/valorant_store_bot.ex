defmodule ValorantStoreBot do
  alias Nosedrum.Invoker.Split, as: CommandInvoker
  alias Nosedrum.Storage.ETS, as: CommandStorage
  use Nostrum.Consumer

  @commands %{
    "store" => ValorantStoreBot.Cogs.Store,
    "login" => ValorantStoreBot.Cogs.Login,
  }

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, _data, _ws_state}) do
    Enum.each(@commands, fn {name, cog} -> CommandStorage.add_command([name], cog) end)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    CommandInvoker.handle_message(msg, CommandStorage)
  end

  def handle_event(_data), do: :ok
end
