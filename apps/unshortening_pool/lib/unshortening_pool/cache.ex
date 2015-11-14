defmodule UnshorteningPool.Cache do
  use ExActor.GenServer, export: __MODULE__

  defstart start_link, do: initial_state(%{})

  defcall check(url), state: state, do: reply(state[url] || false)
  defcast add(short, long), state: state do
    new_state Map.put(state, short, long)
  end
end
