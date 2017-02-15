defmodule DequeTest do
  use ExUnit.Case

  test "new" do
    deque = Deque.new(5)
    assert deque.size == 0
    assert deque.max_size == 5
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

  test "enumerable" do
    deque = Enum.reduce(1..6, Deque.new(5), &Deque.append(&2, &1))
    assert Enum.to_list(deque) == [2, 3, 4, 5, 6]
  end

  test "collectable/inspect" do
    deque = Enum.into([1, 2, 3, 4, 5, 6], Deque.new(5))
    assert inspect(deque) == "#Deque<[2, 3, 4, 5, 6]>"
  end
end
