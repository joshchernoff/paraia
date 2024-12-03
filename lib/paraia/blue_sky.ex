defmodule Paraia.BlueSky do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Paraia.Repo
  alias Paraia.BlueSky.User

  def list_dids(limit: limit, offset: offset) do
    from(u in User, select: u.did, where: is_nil(u.handle), limit: ^limit, offset: ^offset)
    |> Repo.all()
  end

  def upsert!(did) do
    Repo.insert!(
      %User{did: did},
      on_conflict: :nothing
    )
  end

  def batch_update(profiles) do
    profiles
    |> Enum.map(&upsert_profile(&1))
  end

  defp upsert_profile(profile) do
    sql = """
    INSERT INTO blue_sky_users (did, handle, display_name, description, avatar, banner, followers_count, follows_count, posts_count, indexed_at, updated_at, inserted_at)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
    ON CONFLICT (did)
    DO UPDATE SET
      handle = EXCLUDED.handle,
      display_name = EXCLUDED.display_name,
      description = EXCLUDED.description,
      avatar = EXCLUDED.avatar,
      banner = EXCLUDED.banner,
      followers_count = EXCLUDED.followers_count,
      follows_count = EXCLUDED.follows_count,
      posts_count = EXCLUDED.posts_count,
      indexed_at = EXCLUDED.indexed_at,
      updated_at = CURRENT_TIMESTAMP,
      inserted_at = CURRENT_TIMESTAMP
    """

    {:ok, datetime, _offset} = DateTime.from_iso8601(profile["createdAt"])
    created_at = datetime |> DateTime.truncate(:second)

    now = DateTime.utc_now(:second)

    params = [
      profile["did"],
      profile["handle"] || "",
      profile["displayName"] || "",
      profile["description"] || "",
      profile["avatar"],
      profile["banner"] || "",
      profile["followersCount"] || 0,
      profile["followsCount"] || 0,
      profile["postsCount"] || 0,
      created_at,
      now,
      now
    ]

    Repo.query(sql, params)
  end

  def search_users(query, page \\ 0) do
    limit = 20
    offset = page * limit

    results =
      from(u in User,
        where:
          fragment(
            "to_tsvector('english', coalesce(?, '') || ' ' || coalesce(?, '') || ' ' || coalesce(?, '')) @@ plainto_tsquery(?)",
            u.handle,
            u.display_name,
            u.description,
            ^query
          ),
        order_by: [desc: u.followers_count],
        limit: ^limit,
        offset: ^offset
      )
      |> Repo.all()

    [count] =
      from(u in User,
        where:
          fragment(
            "to_tsvector('english', coalesce(?, '') || ' ' || coalesce(?, '') || ' ' || coalesce(?, '')) @@ plainto_tsquery(?)",
            u.handle,
            u.display_name,
            u.description,
            ^query
          ),
        select: count(u.did)
      )
      |> Repo.all()

    {results, count}
  end
end
