defmodule UnshorteningPoolTest do
  use ExUnit.Case
  doctest UnshorteningPool

  test "it should unshorten via the the pool" do
    input = [
      "http://buff.ly/1LYD0tp",
      "http://www.google.com",
      "http://t.co/kfLrRZJ1cI",
      "http://fb.me/6RK0qYjJI",
    ]

    expected = [
      "http://learningelixir.joekain.com/how-I-learned-elixir/?utm_content=buffer9a56c&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer",
      "http://www.google.com",
      "http://learningelixir.joekain.com/how-I-learned-elixir/?utm_content=buffer9a56c&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer",
      "https://www.facebook.com/photo.php?fbid=863512007031067",
    ] |> Enum.sort

    assert expected ==
      input
      |> UnshorteningPool.map
      |> Enum.take(4)
      |> Enum.sort
  end
end
