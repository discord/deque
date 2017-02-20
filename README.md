# Deque

[![Master](https://travis-ci.org/hammerandchisel/deque.svg?branch=master)](https://travis-ci.org/hammerandchisel/deque)
[![Hex.pm Version](http://img.shields.io/hexpm/v/deque.svg?style=flat)](https://hex.pm/packages/deque)

Erlang only supports fast prepends to lists while appending requires a full copy. Getting the size of a list is also a
`O(n)` operation. This library implements a deque using two rotating lists to support fast append and prepend as well as
`O(1)` size via an internal counter.

## Features

- Bounded size
- `Enumerable` protocol
- `Collectable` protocol
- `Inspect` protocol

## Caveats

- Compile times get slower as data size increases.
- Getting a key that does not exist is expensive due to try/catch, put at least a `nil` value.
- Creating atoms from strings is not cheap, use `FastGlobal.new`.

## Usage

Add it to `mix.exs`

```elixir
defp deps do
  [{:deque, "~> 1.0"}]
end
```

And just use it as a global map.

```elixir
deque = Deque.new(5)
deque = Deque.appendleft(1)
deque = Deque.appendleft(2)
deque = Deque.appendleft(3)
3 == Deque.popleft()
```

## License

Deque is released under [the MIT License](LICENSE).
Check [LICENSE](LICENSE) file for more information.