defmodule UnshorteningPool.Cache do
  use ExActor.GenServer, export: __MODULE__

  defstart start_link, do: initial_state(:ets.new(__MODULE__, []))

  defcall check(url), state: table do
    case :ets.lookup(table, url) do
      [{^url, long}] -> reply(long)
      [] -> reply(false)
    end
  end

  defcast add(short, long), state: table do
    :ets.insert(table, {short, long})
    new_state(table)
  end
end
