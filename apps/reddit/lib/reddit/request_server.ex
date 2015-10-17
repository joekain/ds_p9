defmodule Reddit.RequestServer do
  use GenServer

  @delay_seconds 1

  # API
  def start_link, do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def request(endpoint, token, opts) do
    GenServer.call(__MODULE__, {:request, {endpoint, token, opts}})
  end

  def get_oauth_token do
    GenServer.call(__MODULE__, :get_oauth_token)
  end

  # GenServer callbacks
  def init(_) do
    :timer.send_interval(@delay_seconds * 1000, :tick)
    {:ok, :queue.new}
  end

  def handle_call({:request, params}, from, queue) do
    {:noreply, :queue.in({from, params}, queue)}
  end

  def handle_call(:get_oauth_token, _, queue) do
    {:reply, request_oauth_token, queue}
  end

  def handle_info(:tick, queue) do
    process_pop(:queue.out(queue))
  end

  # Private severside functions

  defp process_pop({:empty, queue}), do: {:noreply, queue}
  defp process_pop({{_, {from, {endpoint, token, opts}}}, queue}) do
    GenServer.reply(from, reddit_request(endpoint, token, opts))
    {:noreply, queue}
  end

  defp reddit_request(endpoint, token, opts) do
    HTTPotion.get("https://oauth.reddit.com/" <> endpoint <> query(opts), [headers: [
      "User-Agent": "josephkain-test/0.1 by josephkain",
      "Authorization": "bearer #{token}"
    ]])
    |> Map.get(:body)
    |> Poison.decode
  end

  defp query(opts) do
    string = opts
    |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
    |> Enum.join("&")

    "?" <> string
  end

  defp request_oauth_token do
    cfg = config

    HTTPotion.post("https://www.reddit.com/api/v1/access_token", [
      body: 'grant_type=password&username=#{cfg[:user]}&password=#{cfg[:pass]}',
      headers: [
        "User-Agent": "josephkain-test",
        "Content-Type": "application/x-www-form-urlencoded"
      ],
      basic_auth: {cfg[:client_id], cfg[:secret]}
    ])
    |> Map.get(:body)
    |> Poison.decode
  end

  defp config do
    %{
      user: System.get_env("REDDIT_USER"),
      pass: System.get_env("REDDIT_PASSWORD"),
      client_id: System.get_env("REDDIT_CLIENT_ID"),
      secret: System.get_env("REDDIT_SECRET")
    }
  end
end
