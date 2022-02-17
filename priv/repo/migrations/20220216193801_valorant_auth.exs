defmodule ValorantStoreBot.Repo.Migrations.ValorantAuth do
  use Ecto.Migration

  def change do
    create table(:valorant_auth) do
      add :discord_user_id, :string
      add :username,        :string
      add :password,        :string
      add :player_name,     :string
    end
  end
end
