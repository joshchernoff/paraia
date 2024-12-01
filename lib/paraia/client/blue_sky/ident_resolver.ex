defmodule Paraia.Client.BlueSky.IdentResolver do
  @moduledoc """
  A module to resolve identities based on DID.

  ## Example Usage

      did = "did:plc:1234abcd5678efgh"
      {:ok, handle} = HttpClient.BlueSky.IdentResolver.resolve_handle(did)
      {:ok, profile} = HttpClient.BlueSky.IdentResolver.get_profile(handle)

      IO.inspect(profile)
  """

  @api_base "https://bsky.social/xrpc"

  @spec resolve_handle(String.t()) :: {:ok, String.t()} | {:error, any()}
  def resolve_handle(did) do
    url = "#{@api_base}/com.atproto.identity.resolveHandle?did=#{URI.encode(did)}"

    case Req.get(url) do
      {:ok, %{status: 200, body: %{"handle" => handle}}} -> {:ok, handle}
      {:ok, %{status: status, body: body}} -> {:error, {:http_error, status, body}}
      {:error, reason} -> {:error, {:request_failed, reason}}
    end
  end

  @spec get_profile(String.t()) :: {:ok, map()} | {:error, any()}
  def get_profile(handle) do
    url = "#{@api_base}/app.bsky.actor.getProfile?actor=#{URI.encode(handle)}"

    case Req.get(url) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: status, body: body}} -> {:error, {:http_error, status, body}}
      {:error, reason} -> {:error, {:request_failed, reason}}
    end
  end
end
