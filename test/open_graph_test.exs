defmodule OpenGraphTest do
  use ExUnit.Case, async: true
  doctest OpenGraph

  import OpenGraph
  alias OpenGraph.Error

  @html """
  <html prefix="og: https://ogp.me/ns#">
  <head>
  <title>The Rock (1996)</title>
  <meta property="og:title" content="The Rock" />
  <meta property="og:type" content="video.movie" />
  <meta property="og:url" content="https://www.imdb.com/title/tt0117500/" />
  <meta property="og:image" content="https://ia.media-imdb.com/images/rock.jpg" />
  <meta property="og:image" content="https://ia.media-imdb.com/images/rock2.jpg" />
  <meta property="og:audio" content="https://example.com/bond/theme.mp3" />
  <meta property="og:description" content="brief description" />
  <meta property="og:determiner" content="the" />
  <meta property="og:locale" content="en_GB" />
  <meta property="og:locale:alternate" content="fr_FR" />
  <meta property="og:locale:alternate" content="es_ES" />
  <meta property="og:site_name" content="IMDb" />
  <meta property="og:video" content="https://example.com/bond/trailer.swf" />
  </head>
  </html>
  """

  @expected %OpenGraph{
    title: "The Rock",
    type: "video.movie",
    url: "https://www.imdb.com/title/tt0117500/",
    image: "https://ia.media-imdb.com/images/rock.jpg",
    audio: "https://example.com/bond/theme.mp3",
    description: "brief description",
    determiner: "the",
    locale: "en_GB",
    site_name: "IMDb",
    video: "https://example.com/bond/trailer.swf"
  }

  test "parse/1 succeeds for standard meta tags" do
    assert @expected = parse(@html)
  end

  test "parse/1 succeeds for non-standard meta tags" do
    assert %OpenGraph{
             url: nil,
             site_name: "IMDb",
             locale: "en_GB",
             title: nil,
             type: "video.movie"
           } =
             parse("""
             <meta property="og:url" />
             <meta property="og::site_name" content="IMDb" />
             <meta property="og:site_name" content="IMDb" />
             <meta content="en_GB" property="og:locale" />
             <meta property=" og:title " content="The Rock" />
             <meta property="og:type" content="video.movie">
             """)
  end

  test "fetch!/1 succeeds for 200 OK request" do
    Req.Test.stub(MyStub, &Req.Test.html(&1, @html))

    assert @expected = fetch!("https://example.com/")
  end

  test "fetch!/1 succeeds for 302 redirect request" do
    Req.Test.expect(MyStub, fn conn ->
      conn
      |> Plug.Conn.put_resp_header("location", "https://example.com/")
      |> Plug.Conn.send_resp(302, "found")
    end)

    Req.Test.expect(MyStub, &Plug.Conn.send_resp(&1, 200, @html))

    assert @expected = fetch!("https://example.com/redirect")
  end

  test "fetch!/1 raises exception for redirect missing location in HTTP headers" do
    Req.Test.stub(MyStub, &Plug.Conn.send_resp(&1, 302, "found"))

    assert_raise Error,
                 "redirect response is received but location not found in HTTP headers. HTTP status code: 302",
                 fn ->
                   fetch!("https://example.com/redirect")
                 end
  end

  test "fetch!/1 raises exception for unexpected status code" do
    Req.Test.stub(MyStub, &Plug.Conn.send_resp(&1, 500, "internal server error"))

    assert_raise Error, "unexpected response is received. HTTP status code: 500", fn ->
      fetch!("https://example.com/")
    end
  end

  test "fetch!/1 raises exception for unexpected response format" do
    data = %{"title" => "The Rock"}
    Req.Test.stub(MyStub, &Req.Test.json(&1, data))

    assert_raise Error,
                 "unexpected response format is received. body: #{inspect(data)}",
                 fn ->
                   fetch!("https://example.com/")
                 end
  end

  test "fetch!/1 raises exception for server downtime" do
    Req.Test.stub(MyStub, &Req.Test.transport_error(&1, :econnrefused))

    assert_raise Error, "request error. reason: connection refused", fn ->
      fetch!("https://example.com/")
    end
  end
end
