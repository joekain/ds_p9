defmodule Reddit.Parser do
  @uri_regex ~r<https*://[^\s]+>

  @typep comment_t :: map()

  @spec text(comment_t) :: String.t
  def text(comment) do
    get_body(comment)
  end

  @spec urls(comment_t) :: [ String.t ]
  def urls(comment) do
    comment
    |> get_body
    |> parse_urls
  end

  @spec get_body(comment_t) :: String.t
  defp get_body(comment) do
    comment["data"]["body"] || comment["data"]["url"] || ""
  end

  @spec parse_urls(String.t) :: String.t
  defp parse_urls(body) do
    @uri_regex
    |> Regex.scan(body)
    |> List.flatten
  end
end
