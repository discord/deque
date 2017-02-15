defmodule DequeBench do
  use Benchfella

  @data Enum.to_list(0..200)
  @max_size 100

  bench "deque" do
    Enum.reduce(@data, Deque.new(@max_size), &Deque.append(&2, &1))
    :ok
  end
end
