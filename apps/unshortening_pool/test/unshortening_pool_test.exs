defmodule UnshorteningPoolTest do
  use ExUnit.Case
  doctest UnshorteningPool

  def input, do: [
    "http://buff.ly/1LYD0tp",
    "http://www.google.com",
    "http://t.co/kfLrRZJ1cI",
    "http://fb.me/6RK0qYjJI",
  ]

  def expected, do: [
    "http://learningelixir.joekain.com/how-I-learned-elixir/?utm_content=buffer9a56c&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer",
    "http://www.google.com",
    "http://learningelixir.joekain.com/how-I-learned-elixir/?utm_content=buffer9a56c&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer",
    "https://www.facebook.com/photo.php?fbid=863512007031067",
  ] |> Enum.sort

  test "it should unshorten via the the pool" do
    assert expected ==
      input
      |> UnshorteningPool.map
      |> Enum.take(4)
      |> Enum.sort
  end

  test "it should implement Collectable" do
    Enum.into(input, UnshorteningPool.pool)

    assert expected ==
      UnshorteningPool.output_stream
      |> Enum.take(4)
      |> Enum.sort
  end
end
