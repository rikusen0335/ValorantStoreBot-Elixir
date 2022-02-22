defmodule Storage.AuthETS do
  @moduledoc """
  This module handles the authentication state to handle interaction.

  To use update the state:
  Storage.AuthETS.update(interaction.member.user.id, "2fa", %{})

  state_name varity are:
  "store", "auth", "2fa"
  """

  alias Nostrum.Snowflake

  def init_table do
    :ets.new(:auth_ets, [:set, :protected, :named_table])
  end

  @doc """
  Will handle only just update the state
  状態の更新のみを扱う
  """
  @spec update(Snowflake.t(), String.t(), map()) :: true
  def update(discord_user_id, state_name, state_map) do
    :ets.insert(:auth_ets, {discord_user_id, state_name, state_map})
  end
end
