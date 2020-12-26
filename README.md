# ARQ

Dead simple [Automatic Request Repeat](https://en.wikipedia.org/wiki/Automatic_repeat_request) implementation for independent messages.

Local party sends messages by providing an mfa or a fun/0 to `ARQ.start/2`.

Upon receipt of message, remote party can acknowledge the message (and stop its repeat) by calling `ARQ.stop/1` or sending `:stop` to the requestor process.

## Example:
```elixir
receiver =
  spawn(fn ->
    receive do
      {sender, msg} ->
        IO.puts "Received #{inspect msg} from #{inspect sender}, telling it to stop."
        ARQ.stop(sender)
    end
  end)

ARQ.start(fn -> send(receiver, {self(), :hi}) end)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `arq` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:arq, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/arq](https://hexdocs.pm/arq).
