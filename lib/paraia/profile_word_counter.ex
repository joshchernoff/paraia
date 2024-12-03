defmodule Paraia.ProfileWordCounter do
  use GenServer

  # Client API
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def count_words_and_write_to_file do
    # Start a transaction to query descriptions from DB
    Paraia.Repo.transaction(fn ->
      Ecto.Adapters.SQL.stream(Paraia.Repo, "SELECT description FROM blue_sky_users", [],
        timeout: :infinity
      )
      |> Stream.each(&process_description(&1))
      |> Stream.run()
    end)
  end

  defp process_description(%{rows: rows}) do
    # Flatten the list and filter out nil or empty values
    description =
      rows
      |> List.flatten()
      # Remove nil and non-binary elements
      |> Enum.filter(&(&1 && is_binary(&1)))
      # Convert the cleaned-up list into a string
      |> List.to_string()

    # Count words in the description
    word_counts = count_words(description)

    # Store the counts in GenServer state
    GenServer.cast(__MODULE__, {:update_counts, word_counts})

    # Write the counts to file, passing the file handle
    GenServer.call(__MODULE__, {:write_counts, word_counts})
  end

  defp count_words(description) do
    # Split the description into words and count them
    description
    # Split by spaces or newlines
    |> String.split(~r/\s+/)
    |> Enum.reduce(%{}, fn word, acc ->
      word = String.downcase(word) |> String.trim()
      Map.update(acc, word, 1, &(&1 + 1))
    end)
  end

  defp write_counts_to_file(word_counts, file) do
    # Write the word counts to the file
    Enum.each(word_counts, fn {word, count} ->
      IO.write(file, "#{word},#{count}\n")
    end)
  end

  # GenServer Callbacks
  def init(:ok) do
    # Attempt to open the file and handle any errors
    case File.open("word_counts.txt", [:write, :utf8, :line]) do
      {:ok, file} ->
        {:ok, %{file: file, counts: %{}}}

      {:error, reason} ->
        {:stop, {:file_error, reason}}
    end
  end

  def handle_cast({:update_counts, word_counts}, state) do
    # Merge new counts into existing counts
    updated_counts =
      Map.merge(state.counts, word_counts, fn _word, old_count, new_count ->
        old_count + new_count
      end)

    {:noreply, %{state | counts: updated_counts}}
  end

  def handle_call({:write_counts, word_counts}, _from, state) do
    # Write the word counts to file using the file handle from state
    write_counts_to_file(word_counts, state.file)

    {:reply, :ok, state}
  end

  def terminate(_reason, state) do
    # Ensure the file is closed when the GenServer terminates
    File.close(state.file)
    :ok
  end
end
