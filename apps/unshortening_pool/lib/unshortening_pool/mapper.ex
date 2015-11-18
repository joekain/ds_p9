defmodule UnshorteningPool.Mapper do
  def collect(enum, pool), do: stream_through_pool(enum, pool)

  def map_through_pool(enum, pool) do
    enum
    |> resource(pool)
    |> extract_and_checkin(pool)
  end

  defp resource(enum, pool) do
    Stream.resource(
      fn ->
        spawn_link fn -> stream_through_pool(enum, pool) end
      end,

      fn _ -> {[BlockingQueue.pop(UnshorteningPool.output_queue)], nil} end,
      fn _ -> true end
    )
  end

  defp stream_through_pool(enum, pool) do
    enum
    |> Stream.map(fn x -> {x, :poolboy.checkout(pool)} end)
    |> Stream.map(fn {x, worker} -> UnshorteningPool.Worker.work(worker, x) end)
    |> Stream.run
  end

  defp push_item_through_pool(x, pool) do
    :poolboy.checkout(pool)
    |> UnshorteningPool.Worker.work(x)
  end

  defp extract_and_checkin(stream, pool) do
    Stream.map stream, fn {worker, result} ->
      :poolboy.checkin(pool, worker)
      result
    end
  end

  def output_stream(pool) do
    BlockingQueue.pop_stream(UnshorteningPool.output_queue)
    |> extract_and_checkin(pool)
  end

  def into(pool) do
    { nil, &into(pool, &1, &2) }
  end

  defp into(pool,  _, {:cont, item}), do: push_item_through_pool(item, pool)
  defp into(_pool, _, :done), do: %UnshorteningPool{}
  defp into(_pool, _, :halt), do: :ok
end
