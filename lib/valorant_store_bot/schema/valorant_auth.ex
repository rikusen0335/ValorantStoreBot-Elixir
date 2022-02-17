defmodule ValorantAuth do
  use Ecto.Schema

  # weather is the DB table
  schema "valorant_auth" do
    field :discord_user_id, :string
    field :username,        :string
    field :password,        :string
    field :player_name,     :string
  end

  def changeset(valorant_auth, params \\ %{}) do
    valorant_auth
    |> Ecto.Changeset.cast(params, [:discord_user_id, :username, :password, :player_name])
    |> Ecto.Changeset.unique_constraint([:discord_user_id])
  end
end
