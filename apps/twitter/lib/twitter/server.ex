defmodule Twitter.Server do
  use ExActor.GenServer, export: {:global, :calculator}

  defstart start_link() do
    configure_extwitter

    stream = Twitter.Fetcher.fetch
    |> Stream.flat_map(fn tweet -> Twitter.Parser.urls(tweet) end)

    initial_state(stream)
  end

  defcall get, state: stream, do: reply(stream)

  defp configure_extwitter do
    ExTwitter.configure [
       consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
       consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
       access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
       access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
    ]
  end
end
