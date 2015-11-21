defmodule Producer.Worker do
  use ExActor.GenServer

  # Just start up the evaluation
  defstart start_link(module) do
    pid = spawn_link fn ->
      module.get
      |> Enum.into(UnshorteningPool.pool)
    end

    initial_state(pid)
  end
end
