# ogp

This project, `ogp`, is an Elixir library designed to parse and extract [Open Graph protocol](https://ogp.me/) data from HTML web pages. The Open Graph protocol enables any web page to become a rich object in a social graph.

The library fetches a given URL, parses the HTML content, and extracts the `og:` properties (e.g., `og:title`, `og:image`, `og:description`) from the `<meta>` tags in the page's `<head>`.

## API Usage

The main module to interact with is `OpenGraph`.

### Fetching from a URL

To fetch and parse Open Graph data from a URL, you can use `OpenGraph.fetch/2` or `OpenGraph.fetch!/2`.

`fetch/2` returns a tagged tuple:

```elixir
iex> {:ok, og} = OpenGraph.fetch("https://github.com")
iex> og.title
"GitHub: Let’s build from here"
```

`fetch!/2` returns the `OpenGraph` struct directly or raises an error if something goes wrong.

```elixir
iex> og = OpenGraph.fetch!("https://github.com")
iex> og.site_name
"GitHub"
```

You can also pass options to the underlying `Req` HTTP client:

```elixir
iex> OpenGraph.fetch("https://github.com", [timeout: 5000])
```

### Parsing from a String

If you already have the HTML content, you can use `OpenGraph.parse/1` to extract the Open Graph data.

```elixir
iex> html = "<meta property='og:title' content='My Awesome Page' />"
iex> og = OpenGraph.parse(html)
iex> og.title
"My Awesome Page"
```
