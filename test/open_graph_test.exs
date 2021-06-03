defmodule OpenGraphTest do
  use ExUnit.Case, async: true
  doctest OpenGraph

  import OpenGraph
  alias OpenGraph.Error

  setup do
    bypass = Bypass.open()
    [bypass: bypass]
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"

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

  test "parse/1 returns OpenGraph struct" do
    assert @expected = parse(@html)
  end

  test "parse/1 returns OpenGraph struct for HTML contains invalid meta tags" do
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

  test "fetch!/1 succeeds for direct URL", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/", fn conn ->
      Plug.Conn.resp(conn, 200, @html)
    end)

    assert @expected = fetch!(endpoint_url(bypass.port))
  end

  test "fetch!/1 succeeds for redirect URL", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn =
        Plug.Conn.put_resp_header(conn, "location", endpoint_url(bypass.port) <> "/redirected")

      Plug.Conn.resp(conn, 301, "")
    end)

    Bypass.expect_once(bypass, "GET", "/redirected", fn conn ->
      Plug.Conn.resp(conn, 200, @html)
    end)

    assert @expected = fetch!(endpoint_url(bypass.port))
  end

  test "fetch!/1 raises redirect failed exception when missing location for redirected URL", %{
    bypass: bypass
  } do
    Bypass.expect_once(bypass, fn conn ->
      Plug.Conn.resp(conn, 301, "")
    end)

    assert_raise Error, ~r/redirect failed/, fn ->
      fetch!(endpoint_url(bypass.port))
    end
  end

  test "fetch!/1 raises response unexpected exception for unexpected status code", %{
    bypass: bypass
  } do
    Bypass.expect_once(bypass, fn conn ->
      Plug.Conn.resp(conn, 500, "Internal Server Error")
    end)

    assert_raise Error, ~r/response unexpected/, fn ->
      fetch!(endpoint_url(bypass.port))
    end
  end

  test "fetch!/1 raises request failed exception for server downtime", %{bypass: bypass} do
    Bypass.down(bypass)

    assert_raise Error, ~r/request failed/, fn ->
      fetch!(endpoint_url(bypass.port))
    end
  end

  test "fetch/1 succeeds for direct URL", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/", fn conn ->
      Plug.Conn.resp(conn, 200, @html)
    end)

    assert {:ok, @expected} = fetch(endpoint_url(bypass.port))
  end

  test "fetch/1 succeeds for redirect URL", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn =
        Plug.Conn.put_resp_header(conn, "location", endpoint_url(bypass.port) <> "/redirected")

      Plug.Conn.resp(conn, 301, "")
    end)

    Bypass.expect_once(bypass, "GET", "/redirected", fn conn ->
      Plug.Conn.resp(conn, 200, @html)
    end)

    assert {:ok, @expected} = fetch(endpoint_url(bypass.port))
  end

  test "fetch/1 returns redirect failed error when missing location for redirected URL", %{
    bypass: bypass
  } do
    Bypass.expect_once(bypass, fn conn ->
      Plug.Conn.resp(conn, 301, "")
    end)

    assert {:error, {:redirect_failed, 301}} = fetch(endpoint_url(bypass.port))
  end

  test "fetch/1 returns response unexpected error for unexpected status code", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      Plug.Conn.resp(conn, 500, "Internal Server Error")
    end)

    assert {:error, {:response_unexpected, 500}} = fetch(endpoint_url(bypass.port))
  end

  test "fetch/1 returns request failed error for server downtime", %{bypass: bypass} do
    Bypass.down(bypass)

    assert {:error, {:request_failed, :econnrefused}} = fetch(endpoint_url(bypass.port))
  end
end
