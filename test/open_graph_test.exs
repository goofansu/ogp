defmodule OpenGraphTest do
  use ExUnit.Case
  doctest OpenGraph

  test "parse HTML" do
    html = """
    <meta property="og:title" content="The Rock" />
    <meta property="og:type" content="video.movie" />
    <meta property="og:url" content="https://www.imdb.com/title/tt0117500/" />
    <meta property="og:image" content="https://ia.media-imdb.com/images/rock.jpg" />
    <meta property="og:image" content="https://ia.media-imdb.com/images/rock2.jpg" />
    <meta property="og:audio" content="https://example.com/bond/theme.mp3" />
    <meta property="og:description"
      content="Sean Connery found fame and fortune as the
              suave, sophisticated British agent, James Bond." />
    <meta property="og:determiner" content="the" />
    <meta property="og:locale" content="en_GB" />
    <meta property="og:locale:alternate" content="fr_FR" />
    <meta property="og:locale:alternate" content="es_ES" />
    <meta property="og:site_name" content="IMDb" />
    <meta property="og:video" content="https://example.com/bond/trailer.swf" />
    """

    assert %OpenGraph{
             title: "The Rock",
             type: "video.movie",
             url: "https://www.imdb.com/title/tt0117500/",
             image: "https://ia.media-imdb.com/images/rock.jpg",
             audio: "https://example.com/bond/theme.mp3",
             description: "Sean Connery found fame and fortune as the
          suave, sophisticated British agent, James Bond.",
             determiner: "the",
             locale: "en_GB",
             site_name: "IMDb",
             video: "https://example.com/bond/trailer.swf"
           } = OpenGraph.parse(html)
  end

  test "fetch URL" do
    assert %OpenGraph{
             site_name: "GitHub",
             url: "https://github.com/"
           } = OpenGraph.fetch("https://github.com")
  end

  test "fetch and follow redirect URL" do
    assert %OpenGraph{
             site_name: "Product Hunt",
             url: "https://www.producthunt.com/"
           } = OpenGraph.fetch("https://producthunt.com")
  end
end
