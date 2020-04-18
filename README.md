# Intercooler

This library contains a Plug to support [Intercooler.js][1] requests in your
Plug or Phoenix application.

## Installation and usage

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `intercooler` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:intercooler, "~> 0.1.0"}
  ]
end
```

Once installed, you only need to add this Plug to your pipeline:

```elixir
plug Intercooler.Plug
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/intercooler](https://hexdocs.pm/intercooler).

[1]: https://intercoolerjs.org/
