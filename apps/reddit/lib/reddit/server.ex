defmodule Reddit.Server do
  use ExActor.GenServer, export: {:global, __MODULE__}

  defstart start_link() do
    stream = Reddit.Fetcher.fetch
    # |> Stream.flat_map(fn tweet -> Twitter.Parser.urls(tweet) end)

    initial_state(stream)
  end

  defcall get, state: stream, do: reply(stream)
end
