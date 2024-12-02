defmodule Paraia.Repo.Migrations.AddProfileFieldsToBlueSkyUsers do
  use Ecto.Migration

  def change do
    alter table(:blue_sky_users) do
      add :handle, :string
      add :display_name, :string
      add :description, :string
      add :avatar, :string
      add :banner, :string
      add :followers_count, :integer
      add :follows_count, :integer
      add :posts_count, :integer
      add :indexed_at, :utc_datetime
    end
  end
end
