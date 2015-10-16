defmodule Reddit do
  def get_oauth_token do
    request_oauth_token().body
    |> Poison.decode
    |> ok
    |> Map.get("access_token")
  end

  defp request_oauth_token do
    cfg = config

    HTTPotion.post "https://www.reddit.com/api/v1/access_token", [
      body: 'grant_type=password&username=#{cfg[:user]}&password=#{cfg[:pass]}',
      headers: [
        "User-Agent": "josephkain-test",
        "Content-Type": "application/x-www-form-urlencoded"
      ],
      basic_auth: {cfg[:client_id], cfg[:secret]}
    ]
  end

  defp config do
    %{
      user: System.get_env("REDDIT_USER"),
      pass: System.get_env("REDDIT_PASSWORD"),
      client_id: System.get_env("REDDIT_CLIENT_ID"),
      secret: System.get_env("REDDIT_SECRET")
    }
  end

  def get_new(token, subreddit, opts \\ []) do
    request("/r/#{subreddit}/new", token, opts)
  end

  def get_hot(token, subreddit, opts \\ []) do
    request("/r/#{subreddit}/hot", token, opts)
  end

  def get_comments(token, subreddit, id) do
    request("/r/#{subreddit}/comments/#{id}", token, [limit: 100])
  end

  defp request(endpoint, token, opts) do
    HTTPotion.get("https://oauth.reddit.com/" <> endpoint <> query(opts), [headers: [
      "User-Agent": "josephkain-test/0.1 by josephkain",
      "Authorization": "bearer #{token}"
    ]])
    |> Map.get(:body)
    |> Poison.decode
    |> ok
  end

  defp query(opts) do
    string = opts
    |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
    |> Enum.join("&")

    "?" <> string
  end

  defp ok({:ok, result}), do: result

  def fetch_100_new(token, sub, opts) do
    result = get_new(token, sub, [limit: 100] ++ opts)
    {result["data"]["children"], result["data"]["after"]}
  end

  def fetch_100_hot(token, sub, opts \\ []) do
    result = get_hot(token, sub, [limit: 3] ++ opts)
    result["data"]["children"]
  end

  def fetch_new_perpertually(token, sub) do
    Stream.resource(fn -> [] end,
                    fn next -> fetch_100_new(token, sub, [after: next]) end,
                    fn _ -> true end)
  end

  def fetch_hot_perpertually(token, sub) do
    Stream.repeatedly(fn -> fetch_100_hot(token, sub) end)
    |> Stream.flat_map(fn x -> x end)  # flatten
    # fetch_100_hot(token, sub)
  end

  def test do
    sub = "programming"

    token = get_oauth_token
    |> fetch_hot_perpertually(sub)
    |> Stream.map(fn item -> item["data"]["id"] end)
    # |> Stream.map(fn id -> get_comments(token, sub, id) end)
    |> Stream.map(fn item -> IO.inspect item end)
    |> Stream.run
  end
end
