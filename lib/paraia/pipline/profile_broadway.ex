defmodule Paraia.Pipline.ProfileBroadway do
  use Broadway

  alias Broadway.Message
  alias Paraia.Pipline.DidProducer

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {DidProducer, []},
        transformer: {__MODULE__, :transform, []},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 20
        ]
      ],
      batchers: [
        default: [
          concurrency: 3
        ],
        insert_all: [
          batch_size: 5,
          batch_timeout: 1_000
        ]
      ]
    )
  end

  def transform(event, _options) do
    %Message{
      data: event,
      acknowledger: {__MODULE__, :did, []}
    }
  end

  def ack(:did, _successful, _failed) do
    :ok
  end

  @impl true
  def handle_message(_, %Message{data: data} = message, _) do
    {:ok, result} = Paraia.Client.BlueSky.IdentResolver.get_profiles(data)

    Message.update_data(message, fn _ -> [result] end)
  end

  @impl true
  def handle_batch(:default, messages, _batch_info, _context) do
    messages
    |> Enum.map(fn %Broadway.Message{data: [%{"profiles" => profiles}]} -> profiles end)
    |> List.flatten()
    |> Paraia.BlueSky.batch_update()

    messages
  end
end
