defmodule Paraia.DidStorage do
  @moduledoc """
  A GenServer to store unique DIDs and periodically process them.
  """

  use GenServer

  # Public API

  @doc """
  Starts the GenServer.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Adds a DID to the storage.
  Only stores unique DIDs.
  """
  def add_did(did) when is_binary(did) do
    GenServer.call(__MODULE__, {:add_did, did})
  end

  @doc """
  Retrieves the list of all stored unique DIDs.
  """
  def get_dids do
    GenServer.call(__MODULE__, :get_dids)
  end

  # Callbacks

  @impl true
  def init(_) do
    {:ok, MapSet.new()}
  end

  @impl true
  def handle_call({:add_did, did}, _from, state) do
    if MapSet.member?(state, did) do
      {:reply, :already_exists, state}
    else
      {:reply, :ok, MapSet.put(state, did)}
    end
  end

  @impl true
  def handle_call(:get_dids, _from, state) do
    {:reply, MapSet.to_list(state), state}
  end

  @impl true
  def handle_info(:process_dids, state) do
    # Placeholder for future repo logic
    IO.inspect(MapSet.to_list(state), label: "Processing DIDs")

    # Reset state after processing
    {:noreply, MapSet.new()}
  end

  # Periodically trigger `:process_dids`
  def handle_info(:timeout, state) do
    # 60 seconds
    Process.send_after(self(), :process_dids, 60_000)
    {:noreply, state}
  end
end
