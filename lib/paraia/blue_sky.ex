defmodule Paraia.BlueSky do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Paraia.Repo
  alias Paraia.BlueSky.User

  def upsert!(did) do
    Repo.insert!(
      %User{did: did},
      on_conflict: :nothing
    )
  end
end
