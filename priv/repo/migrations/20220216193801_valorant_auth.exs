defmodule ValorantStoreBot.Repo.Migrations.ValorantAuth do
  use Ecto.Migration

  def change do
    create table(:valorant_auth) do
      add :discord_user_id, :string
      add :username,        :string
      add :password,        :string
    end
  end
end
