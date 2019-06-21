defmodule Deque do
  @moduledoc """
  A fast deque implementation using 2 rotating lists.
  """

  @opaque t :: %__MODULE__{
    size: integer,
    max_size: integer,
    list1: list,
    list2: list,
  }
  @type value :: term

  defstruct size: 0, max_size: nil, list1: [], list2: []

  @spec new(non_neg_integer) :: t
  def new(max_size \\ 100) do
    %Deque{max_size: max_size}
  end

  @spec append(t, value) :: t
  def append(%Deque{max_size: 0}=deque, _value) do
    deque
  end
  def append(%Deque{size: size, max_size: max_size, list1: [], list2: list2}=deque, value) when size < max_size do
    %{deque | size: size + 1, list2: [value|list2]}
  end
  def append(%Deque{size: size, max_size: max_size, list2: list2}=deque, value) when size < max_size do
    %{deque | size: size + 1, list2: [value|list2]}
  end
  def append(%Deque{list1: [], list2: list2}=deque, value) do
    %{deque | list1: Enum.reverse(list2), list2: []} |> append(value)
  end
  def append(%Deque{list1: [_|list1], list2: list2}=deque, value) do
    %{deque | list1: list1, list2: [value|list2]}
  end

  @spec appendleft(t, value) :: t
    def appendleft(%Deque{max_size: 0}=deque, _value) do
    deque
  end
  def appendleft(%Deque{size: size, max_size: max_size, list1: list1, list2: []}=deque, value) when size < max_size do
    %{deque | size: size + 1, list1: [value|list1]}
  end
  def appendleft(%Deque{size: size, max_size: max_size, list1: list1}=deque, value) when size < max_size do
    %{deque | size: size + 1, list1: [value|list1]}
  end
  def appendleft(%Deque{list1: list1, list2: []}=deque, value) do
    %{deque | list1: [], list2: Enum.reverse(list1)} |> appendleft(value)
  end
  def appendleft(%Deque{list1: list1, list2: [_|list2]}=deque, value) do
    %{deque | list1: [value|list1], list2: list2}
  end

  @spec pop(t) :: {value | nil, t}
  def pop(%Deque{list1: [], list2: []}=deque) do
    {nil, deque}
  end
  def pop(%Deque{size: size, list2: [value|list2]}=deque) do
    {value, %{deque | size: size - 1, list2: list2}}
  end
  def pop(%Deque{list1: list1}=deque) do
    %{deque | list1: [], list2: Enum.reverse(list1)} |> pop
  end

  @spec popleft(t) :: {value | nil, t}
  def popleft(%Deque{list1: [], list2: []}=deque) do
    {nil, deque}
  end
  def popleft(%Deque{size: size, list1: [value|list1]}=deque) do
    {value, %{deque | size: size - 1, list1: list1}}
  end
  def popleft(%Deque{list2: list2}=deque) do
    %{deque | list1: Enum.reverse(list2), list2: []} |> popleft
  end

  @spec last(t) :: value | nil
  def last(%Deque{list1: [], list2: []}), do: nil
  def last(%Deque{list2: [value|_]}), do: value
  def last(%Deque{list1: list1}=deque) do
    %{deque | list1: [], list2: Enum.reverse(list1)} |> last
  end

  @spec first(t) :: value | nil
  def first(%Deque{list1: [], list2: []}), do: nil
  def first(%Deque{list1: [value|_]}), do: value
  def first(%Deque{list2: list2}=deque) do
    %{deque | list1: Enum.reverse(list2), list2: []} |> first
  end

  @spec clear(t) :: t
  def clear(%Deque{max_size: max_size}), do: new(max_size)

  @spec take_while(t, (term -> boolean)) :: t
  def take_while(%Deque{list1: [], list2: []}=deque, _func), do: deque
  def take_while(%Deque{list1: list1, list2: list2}=deque, func) do
    case lazy_take_while(list2, func) do
      # If the tail list halts, then everything in head list is invalid.
      {:halt, list2_n, list2} ->
        %{deque | size: list2_n, list1: [], list2: Enum.reverse(list2)}
      {list2_n, list2} ->
        # Halting does not matter when filtering the head list. Reverse the list
        # before attempting to filter it, it will automatically be reversed again.
        {list1_n, list1} =
          with {:halt, list1_n, list1} <- lazy_take_while(Enum.reverse(list1), func) do
            {list1_n, list1}
          end
        %{deque | size: list1_n + list2_n, list1: list1, list2: Enum.reverse(list2)}
    end
  end

  ## Private

  defp lazy_take_while(list, func), do: lazy_take_while(list, [], 0, func)

  defp lazy_take_while([], acc, n, _func), do: {n, acc}
  defp lazy_take_while([h | t], acc, n, func) do
    if func.(h) do
      lazy_take_while(t, [h | acc], n + 1, func)
    else
      {:halt, n, acc}
    end
  end

  ## Protocols

  defimpl Enumerable do
    def reduce(_, {:halt, acc}, _fun) do
      {:halted, acc}
    end
    def reduce(deque, {:suspend, acc}, fun) do
      {:suspended, acc, &reduce(deque, &1, fun)}
    end
    def reduce(%Deque{list1: list1, list2: list2}, {:cont, acc}, fun) do
      reduce({list1, list2}, {:cont, acc}, fun)
    end
    def reduce({[], []}, {:cont, acc}, _fun) do
      {:done, acc}
    end
    def reduce({[h|list1], list2}, {:cont, acc}, fun) do
      reduce({list1, list2}, fun.(h, acc), fun)
    end
    def reduce({[], list2}, {:cont, acc}, fun) do
      reduce({Enum.reverse(list2), []}, {:cont, acc}, fun)
    end

    def member?(%Deque{list1: list1, list2: list2}, element) do
      {:ok, element in list1 or element in list2}
    end

    def count(%Deque{size: size}) do
      {:ok, size}
    end

    def slice(%Deque{}) do
      {:error, __MODULE__}
    end
  end

  defimpl Collectable do
    def into(original) do
      {original, fn
        deque, {:cont, value} -> Deque.append(deque, value)
        deque, :done -> deque
        _, :halt -> :ok
      end}
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(deque, opts) do
      concat ["#Deque<", Inspect.List.inspect(Enum.to_list(deque), opts), ">"]
    end
  end
end
