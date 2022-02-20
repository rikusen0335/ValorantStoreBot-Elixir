defmodule ValorantStoreBot.Repo.Migrations.AddAuthCookieSession do
  use Ecto.Migration

  def change do
    create table(:cookie_session) do
      add :discord_user_id, :string
      add :cookie,          :string
    end
  end
end
