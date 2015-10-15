defmodule Reddit do
  def get_oauth_token do
    request_oauth_token().body
    |> Poison.decode
    |> ok
    |> Map.get("access_token")
  end

  defp request_oauth_token do
    cfg = config

    response = HTTPotion.post "https://www.reddit.com/api/v1/access_token", [
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

  def get_new(token, subreddit) do
    request("/r/#{subreddit}/new?limit=100", token)
  end

  def get_comments(token, subreddit, id) do
    request("/r/#{subreddit}/comments/#{id}?limit=100", token)
  end

  defp request(endpoint, token) do
    HTTPotion.get("https://oauth.reddit.com/" <> endpoint, [headers: [
      "User-Agent": "josephkain-test/0.1 by josephkain",
      "Authorization": "bearer #{token}"
    ]])
    |> Map.get(:body)
    |> Poison.decode
    |> ok
  end

  defp ok({:ok, result}), do: result

  def test do
    token = get_oauth_token
    all = get_new(token, "programming")

    all["data"]["children"]
    |> Stream.map(fn item -> Map.get(item, "data") end)
    |> Stream.map(fn item -> Map.get(item, "id") end)
    |> Stream.map(fn id -> get_comments(token, "programming", id) end)
    |> Stream.map(fn item -> IO.inspect item end)
    |> Stream.run
  end
end
