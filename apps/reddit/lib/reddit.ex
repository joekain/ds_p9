defmodule Reddit do
  def get_oauth_token do
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
end
