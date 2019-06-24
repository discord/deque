defmodule DequeTest do
  use ExUnit.Case

  test "new" do
    0..10
    |> Enum.each(fn max_size ->
      deque = Deque.new(max_size)
      assert deque.size == 0
      assert deque.max_size == max_size
    end)
  end

  test "append/appendleft/pop/popleft" do
    deque = Enum.reduce(1..6, Deque.new(5), &Deque.append(&2, &1))
    assert deque.list1 == [2, 3, 4, 5]
    assert deque.list2 == [6]

    deque = Enum.reduce(7..9, deque, &Deque.append(&2, &1))
    assert deque.list1 == [5]
    assert deque.list2 == [9, 8, 7, 6]

    deque = Enum.reduce(1..3, deque, &Deque.appendleft(&2, &1))
    assert deque.list1 == [3, 2, 1, 5]
    assert deque.list2 == [6]

    deque = Deque.appendleft(deque, 4)
    assert deque.list1 == [4, 3, 2, 1, 5]
    assert deque.list2 == []

    {value, deque} = Deque.pop(deque)
    assert value == 5
    assert deque.list1 == []
    assert deque.list2 == [1, 2, 3, 4]

    {value, deque} = Deque.popleft(deque)
    assert value == 4
    assert deque.list1 == [3, 2, 1]
    assert deque.list2 == []
  end

  test "append/appendleft/pop/popleft max_size=0" do
    deque = Enum.reduce(1..6, Deque.new(0), &Deque.append(&2, &1))
    assert deque.list1 == []
    assert deque.list2 == []

    deque = Enum.reduce(1..3, deque, &Deque.appendleft(&2, &1))
    assert deque.list1 == []
    assert deque.list2 == []

    {value, deque} = Deque.pop(deque)
    assert value == nil
    assert deque.list1 == []
    assert deque.list2 == []

    {value, deque} = Deque.popleft(deque)
    assert value == nil
    assert deque.list1 == []
    assert deque.list2 == []
  end

  test "enumerable" do
    deque = Enum.reduce(1..6, Deque.new(5), &Deque.append(&2, &1))
    assert Enum.to_list(deque) == [2, 3, 4, 5, 6]

    deque = Enum.reduce(1..6, Deque.new(0), &Deque.append(&2, &1))
    assert Enum.to_list(deque) == []
  end

  test "collectable/inspect" do
    deque = Enum.into(1..6, Deque.new(5))
    assert inspect(deque) == "#Deque<[2, 3, 4, 5, 6]>"

    deque = Enum.into(1..6, Deque.new(0))
    assert inspect(deque) == "#Deque<[]>"
  end

  test "take_while" do
    deque = gen_take_while(498..500, 5, 498)
    assert Enum.to_list(deque) == [499, 500]

    deque = gen_take_while(400..500, 10, 492)
    assert Enum.to_list(deque) == [493, 494, 495, 496, 497, 498, 499, 500]

    deque = gen_take_while(400..500, 0, 492)
    assert Enum.to_list(deque) == []
  end

  defp gen_take_while(range, max_size, max_value) do
    range |> Enum.into(Deque.new(max_size)) |> Deque.take_while(&(&1 > max_value))
  end
end
