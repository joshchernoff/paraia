defmodule Paraia.Repo do
  use Ecto.Repo,
    otp_app: :paraia,
    adapter: Ecto.Adapters.Postgres
end
