defmodule ValorantStoreBot do
  alias Nosedrum.Invoker.Split, as: CommandInvoker
  alias Nosedrum.Storage.ETS, as: CommandStorage

  alias Nostrum.Api

  use Nostrum.Consumer

  @commands %{
    "applycmd" => ValorantStoreBot.Cogs.ApplyCommand,
    "help" => ValorantStoreBot.Cogs.Help,
  }

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, _data, _ws_state}) do
    # ETS for the Application
    Storage.AuthETS.init_table()

    # Normal commands
    Enum.each(@commands, fn {name, cog} -> CommandStorage.add_command([name], cog) end)

    # Slash application commands
    case Nosedrum.Interactor.Dispatcher.add_command("login", ValorantStoreBot.Commands.Login, :global) do
      {:ok, _} -> IO.puts("Registered Login command.")
      e -> IO.inspect(e, label: "An error occurred registering the Login command")
    end

    case Nosedrum.Interactor.Dispatcher.add_command("logout", ValorantStoreBot.Commands.Logout, :global) do
      {:ok, _} -> IO.puts("Registered Logout command.")
      e -> IO.inspect(e, label: "An error occurred registering the Logout command")
    end

    case Nosedrum.Interactor.Dispatcher.add_command("store", ValorantStoreBot.Commands.Store, :global) do
      {:ok, _} -> IO.puts("Registered Store command.")
      e -> IO.inspect(e, label: "An error occurred registering the Store command")
    end

    case Nosedrum.Interactor.Dispatcher.add_command("ping", ValorantStoreBot.Commands.Ping, :global) do
      {:ok, _} -> IO.puts("Registered Ping command.")
      e -> IO.inspect(e, label: "An error occurred registering the Ping command")
    end

    Api.update_status(:online, ".help")
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    CommandInvoker.handle_message(msg, CommandStorage)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    Handler.Interaction.handle(interaction)
    |> case do
      {:ok} -> IO.puts("Responded to interaction")
      {:error, _} -> Nosedrum.Interactor.Dispatcher.handle_interaction(interaction)
    end
  end

  def handle_event(_data), do: :ok
end
