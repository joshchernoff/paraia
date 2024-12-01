defmodule HttpClient.BlueSky.IdentResolver. do
  @moduledoc """
  A module to resolve identies based on DID

  # Example Usage
  did = "did:plc:1234abcd5678efgh"
  {:ok, handle} = BlueskyClient.resolve_handle(did)
  {:ok, profile} = BlueskyClient.get_profile(handle)

  IO.inspect(profile)

  """

  alias Finch.Response

  @api_base "https://bsky.social/xrpc"

  # Fetch handle from DID
  def resolve_handle(did) do
    url = "#{@api_base}/com.atproto.identity.resolveHandle?did=#{did}"

    case Finch.build(:get, url) |> Finch.request(MyAppFinch) do
      {:ok, %Response{status: 200, body: body}} ->
        body |> Jason.decode!() |> Map.get("handle")

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Fetch profile from handle
  def get_profile(handle) do
    url = "#{@api_base}/app.bsky.actor.getProfile?actor=#{handle}"

    case Finch.build(:get, url) |> Finch.request(MyAppFinch) do
      {:ok, %Response{status: 200, body: body}} ->
        Jason.decode!(body)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
