defmodule Storage.AuthETS do

  alias Nostrum.Snowflake

  def init_table do
    :ets.new(:auth_ets, [:set, :protected, :named_table])
  end

  @spec update(Snowflake.t(), tuple()) :: {:ok} | {:error, String.t()}
  def update(discord_user_id, state_tuple) do
    data_tuple? = :ets.lookup(:auth_ets, discord_user_id)

    data_tuple?
    |> is_tuple()
    |> case do
      # It's returning tuple data
      true -> :ets.insert_new()

      # Or else not
      false -> :ets.insert(state_tuple)
    end
    {:ok}
  end
end
