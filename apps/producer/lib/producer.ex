defmodule Producer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Producer.Worker, [Reddit.Server], id: :producer_reddit),
      worker(Producer.Worker, [Twitter.Server], id: :producer_twitter),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Producer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
