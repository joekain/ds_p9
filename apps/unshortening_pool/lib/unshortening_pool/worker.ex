defmodule UnshorteningPool.Worker do
  use ExActor.GenServer

  defstart start_link(_), do: initial_state(0)

  defcast work(url) do
    result = url
    |> check_cache(fn url ->
      UnshorteningPool.Unshortener.expand(url)
    end)

    BlockingQueue.push(UnshorteningPool.output_queue, {self, result})
    new_state(0)
  end

  defp check_cache(url, f) do
    result = UnshorteningPool.Cache.check(url)
    if !result do
      result = f.(url)
      UnshorteningPool.Cache.add(url, result)
    end

    result
  end
end
