# ogp

The [Open Graph protocol](https://ogp.me/) library in Elixir.

[![CI](https://github.com/goofansu/ogp/actions/workflows/ci.yml/badge.svg)](https://github.com/goofansu/ogp/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/goofansu/ogp/badge.svg?branch=main)](https://coveralls.io/github/goofansu/ogp?branch=main)

## Installation

```elixir
def deps do
  [
    {:ogp, "~> 1.1.0"}
  ]
end
```

## Usage

It is recommended to run [ogp.livemd](https://github.com/goofansu/ogp/blob/main/ogp.livemd) in [Livebook](https://github.com/elixir-nx/livebook) for more details.

### Parse HTML

```elixir
iex> html = """
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
<meta property="og:site_name" content="IMDb" />
<meta property="og:video" content="https://example.com/bond/trailer.swf" />
"""
iex> OpenGraph.parse(html)
%OpenGraph{
  audio: "https://example.com/bond/theme.mp3",
  description: "Sean Connery found fame and fortune as the\n           suave, sophisticated British agent, James Bond.",
  determiner: "the",
  image: "https://ia.media-imdb.com/images/rock.jpg",
  locale: "en_GB",
  site_name: "IMDb",
  title: "The Rock",
  type: "video.movie",
  url: "https://www.imdb.com/title/tt0117500/",
  video: "https://example.com/bond/trailer.swf"
}
```

### Fetch URL

```elixir
iex> OpenGraph.fetch!("https://github.com")
%OpenGraph{
  audio: nil,
  description: "GitHub is where over 65 million developers shape the future of software, together. Contribute to the open source community, manage your Git repositories, review code like a pro, track bugs and feat...",
  determiner: nil,
  image: "https://github.githubassets.com/images/modules/site/social-cards/github-social.png",
  locale: nil,
  site_name: "GitHub",
  title: "GitHub: Where the world builds software",
  type: "object",
  url: "https://github.com/",
  video: nil
}
```

Redirects are followed automatically by default.

```elixir
iex> OpenGraph.fetch!("https://producthunt.com")

[debug] redirecting to https://www.producthunt.com/
%OpenGraph{
  title: " Product Hunt – The best new products in tech. ",
  type: "article",
  image: "https://ph-static.imgix.net/ph-logo-1.png",
  url: "https://www.producthunt.com/",
  audio: nil,
  description: "Product Hunt is a curation of the best new products, every day. Discover the latest mobile apps, websites, and technology products that everyone's talking about.",
  determiner: nil,
  locale: "en_US",
  site_name: "Product Hunt",
  video: nil
}
```

You can control redirects by configuring `req_options`.

- Disable redirects:

```elixir
config :ogp,
  req_options: [
    redirect: false
  ]
```

- Set a different `max_redirects` (default is `10`):

```elixir
config :ogp,
  req_options: [
    max_redirects: 3
  ]
```

See https://hexdocs.pm/req/Req.html#new/1-options for the full `req` options.
