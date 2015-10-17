defmodule UnshorteningPool.Worker do
  use ExActor.GenServer

  defstart start_link(_), do: initial_state(0)

  defcast work(url) do
    BlockingQueue.push(UnshorteningPool.output_queue, {self, UnshorteningPool.Unshortener.expand(url)})
    new_state(0)
  end
end
