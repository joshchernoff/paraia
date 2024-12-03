defmodule Paraia.Repo.Migrations.AddTextSearchToDescription do
  use Ecto.Migration

  def up do
    execute """
    CREATE INDEX blue_sky_users_fulltext_index ON blue_sky_users
    USING gin(
      to_tsvector('english', coalesce(handle, '') || ' ' || coalesce(display_name, '') || ' ' || coalesce(description, ''))
    );
    """
  end

  def down do
    execute """
    DROP INDEX blue_sky_users_fulltext_index;
    """
  end
end
