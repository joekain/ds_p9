defmodule Producer.Worker do
  use ExActor.GenServer

  # Just start up the evaluation
  defstart start_link(module) do
    pid = spawn_link fn ->
      module.get
      |> UnshorteningPool.collect
    end

    initial_state(pid)
  end
end
