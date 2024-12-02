defmodule Paraia.Pipline.DidProducer do
  use GenStage

  alias Paraia.BlueSky

  @batch_size 25

  # Initialize the producer with offset 0
  def init(_opts) do
    {:producer, %{offset: 0}}
  end

  def handle_demand(demand, %{offset: offset} = state) do
    # Calculate the new limit based on demand
    total_limit = demand * @batch_size

    # Fetch rows based on the current offset
    rows =
      BlueSky.list_dids(limit: total_limit, offset: offset)
      |> Enum.chunk_every(@batch_size)

    # Calculate the new offset
    new_offset = offset + total_limit

    # Return the rows and update the state with the new offset
    {:noreply, rows, %{state | offset: new_offset}}
  end
end
