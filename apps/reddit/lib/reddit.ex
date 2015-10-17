defmodule Reddit do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(Reddit.RequestServer, []),
      worker(Reddit.Server, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Reddit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def test_runner do
    Reddit.Server.get
    |> Stream.flat_map(fn item -> item["data"]["children"] end)
    |> Stream.map(fn item -> item["data"]["body"] || item["data"]["url"] end)
    |> Stream.map(fn item -> IO.inspect item end)
    |> Stream.run
  end
end
