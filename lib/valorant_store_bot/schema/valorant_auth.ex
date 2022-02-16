defmodule ValorantAuth do
  use Ecto.Schema

  # weather is the DB table
  schema "valorant_auth" do
    field :discord_user_id, :string
    field :username,        :string
    field :password,        :string
  end
end
