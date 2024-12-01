defmodule Paraia.Repo.Migrations.AddBlueSkyUsers do
  use Ecto.Migration

  def change do
    create table(:blue_sky_users, primary_key: false) do
      add :did, :string, primary_key: true
      add :profile, :string
      timestamps(type: :utc_datetime)
    end
  end
end
