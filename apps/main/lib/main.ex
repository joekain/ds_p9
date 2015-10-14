defmodule Main do
  def run do
    Twitter.Server.get
    |> UnshorteningPool.map
    |> Stream.map(fn x -> IO.inspect x end)
    |> Enum.take(10)
    |> Enum.to_list
  end
end
