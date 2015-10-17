defmodule Main do
  def run do
    UnshorteningPool.output_stream
    |> Stream.map(fn x -> IO.inspect x end)
    |> Enum.take(30)
    |> Enum.to_list
  end
end
