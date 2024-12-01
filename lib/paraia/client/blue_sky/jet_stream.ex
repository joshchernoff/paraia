defmodule Paraia.Client.BlueSky.JetStream do
  use WebSockex
  require Logger

  alias Paraia.Client.BlueSky.Authentication

  # fetch from ENV var
  @username
  # fetch from ENV var
  @password

  def start_link(_) do
    url = "wss://jetstream1.us-east.bsky.network/subscribe?wantedCollections[]=app.bsky.feed.post"

    # Attempt authentication before starting the WebSocket connection
    case Authentication.authenticate(@username, @password) do
      {:ok, %{access_token: access_token}} ->
        # If authentication is successful, proceed to start the WebSocket
        WebSockex.start_link(url, __MODULE__, %{access_token: access_token})

      {:error, reason} ->
        Logger.error("Authentication failed: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  def init(state) do
    Logger.info("Successfully authenticated and connected.")
    {:ok, state}
  end

  @impl true
  def handle_connect(_conn, state) do
    Logger.info("Successfully connected to Bluesky Firehose.")
    {:ok, state}
  end

  @impl true
  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, parsed_msg} ->
        # TODO: time to get DID form feed
        parsed_msg

      {:error, reason} ->
        Logger.error("Failed to decode JSON: #{inspect(reason)}")
    end

    {:ok, state}
  end
end
