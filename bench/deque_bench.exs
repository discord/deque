defmodule DequeBench do
  use Benchfella

  bench "Deque.new/1" do
    gen_deque(200, 100)
    :ok
  end

  bench "Enum.take_while/2", [deque: gen_deque(400, 400)] do
    seq = 300
    deque
      |> Enum.reverse
      |> Enum.take_while(&(&1 > seq))
      |> Enum.reverse
      |> Enum.into(Deque.clear(deque))
    :ok
  end

  bench "Deque.take_while/2", [deque: gen_deque(400, 400)] do
    seq = 300
    Deque.take_while(deque, &(&1 > seq))
    :ok
  end

  defp gen_deque(n, max_size) do
    Enum.reduce(0..n, Deque.new(max_size), &Deque.append(&2, &1))
  end
end
