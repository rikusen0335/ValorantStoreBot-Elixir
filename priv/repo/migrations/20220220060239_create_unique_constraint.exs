defmodule ValorantStoreBot.Repo.Migrations.CreateUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:valorant_auth,  [:discord_user_id], name: :valorant_auth_discord_user_id_index)
  end
end
