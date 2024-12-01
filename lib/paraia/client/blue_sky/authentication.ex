defmodule Paraia.Client.BlueSky.Authentication do
  @moduledoc """
  Module for handling Bluesky authentication.
  """

  use GenServer

  @url "https://bsky.social/xrpc/com.atproto.server.createSession"

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(:ok) do
    {:ok, %{}}
  end

  # Public function to authenticate and get a token
  def authenticate(username, password) do
    case get_token() do
      {:ok, access_token} ->
        {:ok, access_token}

      {:error, _} ->
        authenticate_and_store_token(username, password)
    end
  end

  # Fetch the token from Repo or other storage
  defp get_token do
    # case Repo.get_blue_sky_auth() do
    #   [{:tokens, access_token, _refresh_token, expiration}] ->
    #     if expiration > :os.system_time(:second) do
    #       {:ok, access_token}
    #     else
    #       {:error, "Token expired"}
    #     end

    #   [] ->
    #     {:error, "Token not found"}
    # end
    {:error, "Token not found"}
  end

  # Authenticate with Bluesky API and store the token in the Repo
  defp authenticate_and_store_token(username, password) do
    body = %{
      "identifier" => username,
      "password" => password
    }

    case Req.post(@url, json: body) do
      {:ok, %{status: 200, body: response}} ->
        # Store the token in Repo (TODO)
        # Repo.insert_or_update_token(response)

        {:ok, map_auth_response(response)}

      {:ok, %{status: status, body: body}} ->
        {:error, "Request failed with status #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  # Helper function to map authentication response
  defp map_auth_response(%{
         "accessJwt" => access_token,
         "refreshJwt" => refresh_token,
         "did" => did,
         "didDoc" => did_doc,
         "email" => email,
         "emailAuthFactor" => email_auth_factor,
         "emailConfirmed" => email_confirmed,
         "handle" => handle
       }) do
    %{
      access_token: access_token,
      refresh_token: refresh_token,
      did: did,
      did_doc: did_doc,
      email: email,
      email_auth_factor: email_auth_factor,
      email_confirmed: email_confirmed,
      handle: handle
    }
  end
end
