defmodule Reddit do
  def get_oauth_token do
    Reddit.RequestServer.get_oauth_token
    |> ok
    |> Map.get("access_token")
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
    Reddit.RequestServer.request(endpoint, token, opts)
    |> ok
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
  end

  def test do
    Reddit.RequestServer.start_link

    sub = "programming"
    token = get_oauth_token

    token
    |> fetch_hot_perpertually(sub)
    |> Stream.map(fn item -> item["data"]["id"] end)
    |> Stream.flat_map(fn id -> get_comments(token, sub, id) end)
    |> Stream.flat_map(fn item -> item["data"]["children"] end)
    |> Stream.map(fn item -> item["data"]["body"] || item["data"]["url"] end)
    |> Stream.map(fn item -> IO.inspect item end)
    |> Stream.run
  end
end
