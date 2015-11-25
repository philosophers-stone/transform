
defmodule TransformTest do
  use ExUnit.Case

  test "identity is the default atom" do
    assert Transform.transform(:foo,%{}) == :foo
  end

  test "convert to string" do
    potion = %{ Atom => fn(x, _d) -> Atom.to_string(x) end}
    assert Transform.transform(:foo,potion) == "foo"
  end

  test "identity is the default string" do
    assert Transform.transform("foo",%{}) == "foo"
  end

  test "convert string to atom" do
    potion = %{ BitString => fn(x, _d) -> String.to_atom(x) end}
    assert Transform.transform("foo",potion) == :foo
  end

  test "identity is the default Integer" do
    assert Transform.transform(1,%{}) == 1
  end

  test "convert integer to string" do
    potion = %{ Integer => fn(x, _d) -> Integer.to_string(x) end}
    assert Transform.transform(1,potion) == "1"
  end

  test "identity is the default Float" do
    assert Transform.transform(1.0, %{}) == 1.0
  end

  test "convert Float to string" do
    potion = %{ Float => fn(x, _d) -> Float.to_string(x) end}
    assert Transform.transform(5.0, potion) == "5.00000000000000000000e+00"
  end


  test "identity is the default list" do
    assert Transform.transform([1,2,3],%{}) == [1,2,3]
  end

  test "convert list elements to atom" do
    data = ["a", "b", "c"]
    potion = %{ BitString => fn(x, _d) -> String.to_atom(x) end }
    assert Transform.transform(data,potion) == [:a, :b, :c]
  end

  test "convert list to tuple" do
    data = [:a, :b, :c]
    potion = %{ List => fn(x, _d) -> List.to_tuple(x) end }
    assert Transform.transform(data,potion) == {:a, :b, :c}
  end

  test "nested list to nested tuple" do
    data = [[:a], [:b], [:c]]
    potion = %{ List => fn(x, _d) -> List.to_tuple(x) end }
    assert Transform.transform(data,potion) == {{:a}, {:b}, {:c}}
  end

  test "identity is the default keyword" do
    assert Transform.transform([ a: 1, b: 2], %{}) == [a: 1, b: 2]
  end

  test "convert keyword values to atom" do
    data = [a: "a", b: "b", c: "c"]
    potion = %{ BitString => fn(x, _d) -> String.to_atom(x) end }
    assert Transform.transform(data,potion) == [a: :a, b: :b,c: :c]
  end

  test "convert keyword to nested list" do
    data = [a: "a", b: "b", c: "c"]
    potion = %{ Keyword => fn(x, _d) -> for {k, v} <- x, into: [], do: [k, v] end }
    assert Transform.transform(data,potion) == [[:a, "a"], [:b, "b"], [:c, "c"]]
  end

  test "identity is the default tuple" do
    assert Transform.transform({1, 2, 3}, %{}) == {1, 2, 3}
  end

  test "convert tuple elements to atom" do
    data = {"a", "b", "c"}
    potion = %{ BitString => fn(x, _d) -> String.to_atom(x) end }
    assert Transform.transform(data, potion) == {:a, :b, :c}
  end

  test "convert tuple to list" do
    data = {:a, :b, :c}
    potion = %{ Tuple => fn(x, _d) -> Tuple.to_list(x) end }
    assert Transform.transform(data, potion) == [:a, :b, :c]
  end

  test "nested tuple to list" do
    data = {{:a}, {:b}, {:c}}
    potion = %{ Tuple => fn(x, _d) -> Tuple.to_list(x) end }
    assert Transform.transform(data, potion) == [[:a], [:b], [:c]]
  end

  test "identity is the default map" do
    data = %{"a" => 1, "b" => 2}
    assert Transform.transform(data, %{}) == data
  end

  test "convert map to keyword list" do
    data = %{"a" => 1, "b" => 2}
    bar = [a: 1, b: 2]
    to_keyword = fn(m, _d) ->
      for {k, v} <- m , into: [], do: {String.to_atom(k), v}
    end
    potion = %{Map => to_keyword}
    assert Transform.transform(data, potion) == bar
  end

  test "identity is the default struct" do
    assert Transform.transform(1..5, %{}) == 1..5
  end

  test "convert range " do
    potion = %{Range => fn(_r, _d) -> %Range{first: 2, last: 5} end}
    assert Transform.transform(1..5, potion) == 2..5
  end

  test "identity is the default quote do output" do
    data = quote do: Enum.map(1..3, fn(x) -> x*x end) |> Enum.sum
    assert Transform.transform(data, %{}) == data
  end

  test "transform quote do output" do
    data = quote do: Enum.map(1..3, fn(x) -> x*x end)
    data_transform = quote do: Enum.map(1..3, fn(y) -> y*y end)
    replace_x = fn(a, _d ) ->
      case a do
        :x -> :y
        atom -> atom
      end
    end
    potion = %{ Atom => replace_x }
    assert Transform.transform(data, potion) == data_transform
  end

  test "implement scrub of empty values from map" do
    data = %{ :a => nil, :b => "", :c => "a"}
    replace_empty = fn(string, _d) -> if( string == "", do: nil , else: string) end
    replace_nil = fn(map, _depth) ->  for {k, v} <- map, v != nil , into: %{}, do: {k, v} end
    potion = %{ BitString => replace_empty, Map => replace_nil}

    assert Transform.transform(data, potion) == %{:c => "a"}

  end

  test "depth check in nested lists" do
    data = [[[1,2,3],[2,3]]]
    potion = %{ List => fn(list, depth) -> if ( Enum.count(depth) > 1 ), do: :list_too_deep , else: list end }
    assert Transform.transform(data, potion) == [[:list_too_deep,:list_too_deep]]
  end
end