defmodule Paraia.BlueSky.User do
  use Ecto.Schema

  @primary_key false
  schema "blue_sky_users" do
    field :did, :string, primary_key: true
    field :profile, :string
    field :handle, :string
    field :display_name, :string
    field :description, :string
    field :avatar, :string
    field :banner, :string
    field :followers_count, :integer
    field :follows_count, :integer
    field :posts_count, :integer
    field :indexed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end
end
