defmodule Paraia.BlueSky.User do
  use Ecto.Schema

  @primary_key false
  schema "blue_sky_users" do
    field :did, :string, primary_key: true
    field :profile, :string
    timestamps(type: :utc_datetime)
  end
end
