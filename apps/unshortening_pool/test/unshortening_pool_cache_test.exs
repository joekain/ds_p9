defmodule UnshorteningPool.Cache.Test do
  use ExUnit.Case
  alias UnshorteningPool.Cache

  test "It should not hit when empty" do
    assert false == Cache.check("http:///not-found.example.com")
  end

  test "It should hit after loading a value" do
    Cache.add("http:///www.example.com", "http://a-long-url.example.com")
    assert "http://a-long-url.example.com" == Cache.check("http:///www.example.com")
  end

  test "It should be able to change a value" do
    Cache.add("http:///www.example.com", "http://a-long-url.example.com")
    Cache.add("http:///www.example.com", "http://a-different-url.example.com")

    assert "http://a-different-url.example.com" == Cache.check("http:///www.example.com")
  end
end
