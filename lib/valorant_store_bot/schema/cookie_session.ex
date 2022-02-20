defmodule Schema.CookieSession do
  use Ecto.Schema

  # weather is the DB table
  schema "cookie_session" do
    field :discord_user_id, :string
    field :cookie,          :string
  end

  def changeset(cookie_session, params \\ %{}) do
    cookie_session
    |> Ecto.Changeset.cast(params, [:discord_user_id, :cookie])
    |> Ecto.Changeset.unique_constraint([:discord_user_id], name: :cookie_session_discord_user_id_index)
  end
end
