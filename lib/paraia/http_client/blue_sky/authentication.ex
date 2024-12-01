defmodule HttpClient.BlueSky.Authentication do
  @moduledoc """
  Module for handling Bluesky authentication.
  """

  @url "https://bsky.social/xrpc/com.atproto.server.createSession"
  @headers [{"Content-Type", "application/json"}]

  # Initialize the ETS table when starting the Authentication module
  def start_link(_) do
    # TODO: ensure ecto is running

    # Return the correct GenServer start link response
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

  # Initialization callback for the GenServer
  def init(:ok) do
    {:ok, %{}}
  end

  # Single authenticate function that checks the token and re-authenticates if needed
  def authenticate(username, password) do
    case get_token() do
      {:ok, access_token} ->
        {:ok, access_token}

      {:error, _} ->
        # If no valid token, authenticate with username and password
        authenticate_and_store_token(username, password)
    end
    |> dbg()
  end

  # Authenticate the user with Bluesky API and store the token in Repo
  defp authenticate_and_store_token(username, password) do
    body =
      %{
        "identifier" => username,
        "password" => password
      }
      |> Jason.encode!()

    Finch.build(:post, @url, @headers, body)
    |> Finch.request(BlueskyDpBot.Finch)
    |> handle_response()
  end

  # Handle successful authentication response
  defp handle_response({:ok, %Finch.Response{status: 200, body: body}}) do
    case Jason.decode(body) do
      {:ok,
       %{
         "accessJwt" => access_token,
         "refreshJwt" => refresh_token,
         "did" => did,
         "didDoc" => did_doc,
         "email" => email,
         "emailAuthFactor" => email_auth_factor,
         "emailConfirmed" => email_confirmed,
         "handle" => handle
       }} ->
        # Store the token in repo for future use
        # TODO write tocken to Repo

        {:ok,
         %{
           access_token: access_token,
           refresh_token: refresh_token,
           did: did,
           did_doc: did_doc,
           email: email,
           email_auth_factor: email_auth_factor,
           email_confirmed: email_confirmed,
           handle: handle
         }}

      {:error, _} ->
        {:error, "Failed to decode the response body"}
    end
  end

  # Handle failed authentication response
  defp handle_response({:ok, %Finch.Response{status: status, body: body}}) do
    {:error, "Request failed with status #{status}: #{body}"}
  end

  # Handle connection errors
  defp handle_response({:error, reason}) do
    {:error, "Request failed: #{inspect(reason)}"}
  end

  # TODO Fetch the token from Repo
  defp get_token do
    case Repo.get_blue_sky_auth() do
      [{:tokens, access_token, _refresh_token, expiration}] ->
        if expiration > :os.system_time(:second) do
          {:ok, access_token}
        else
          {:error, "Token expired"}
        end

      [] ->
        {:error, "Token not found"}
    end
  end
end
