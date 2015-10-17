defmodule Main do
  def run do
    spawn_link fn ->
      Twitter.Server.get
      |> UnshorteningPool.collect
    end

    UnshorteningPool.output_stream
    |> Stream.map(fn x -> IO.inspect x end)
    |> Enum.take(10)
    |> Enum.to_list
  end
end
