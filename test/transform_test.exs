
defmodule TransformTest do
  use ExUnit.Case

  test "identity is the default atom" do 
    assert Transform.transform(:foo,%{}) == :foo 
  end 

  test "convert to string" do 
    trans = %{ Atom => fn(x, _d) -> Atom.to_string(x) end}
    assert Transform.transform(:foo,trans) == "foo"
  end 

  test "identity is the default string" do 
    assert Transform.transform("foo",%{}) == "foo"
  end 

  test "convert string to atom" do 
    trans = %{ BitString => fn(x, _d) -> String.to_atom(x) end}
    assert Transform.transform("foo",trans) == :foo
  end 

  test "identity is the default Integer" do 
    assert Transform.transform(1,%{}) == 1
  end 

  test "convert integer to string" do 
    trans = %{ Integer => fn(x, _d) -> Integer.to_string(x) end}
    assert Transform.transform(1,trans) == "1"
  end 

  test "identity is the default Float" do 
    assert Transform.transform(1.0, %{}) == 1.0
  end 

  test "convert Float to string" do 
    trans = %{ Float => fn(x, _d) -> Float.to_string(x) end}
    assert Transform.transform(5.0, trans) == "5.00000000000000000000e+00"
  end 


  test "identity is the default list" do 
    assert Transform.transform([1,2,3],%{}) == [1,2,3]
  end 

  test "convert list elements to atom" do 
    foo = ["a", "b", "c"]
    trans = %{ BitString => fn(x, _d) -> String.to_atom(x) end }
    assert Transform.transform(foo,trans) == [:a, :b, :c]
  end 

  test "convert list to tuple" do 
    foo = [:a, :b, :c]
    trans = %{ List => fn(x, _d) -> List.to_tuple(x) end }
    assert Transform.transform(foo,trans) == {:a, :b, :c}
  end 

  test "nested list to nested tuple" do 
    foo = [[:a], [:b], [:c]]
    trans = %{ List => fn(x, _d) -> List.to_tuple(x) end }
    assert Transform.transform(foo,trans) == {{:a}, {:b}, {:c}}
  end 

  test "identity is the default keyword" do 
    assert Transform.transform([ a: 1, b: 2], %{}) == [a: 1, b: 2]
  end 

  test "convert keyword values to atom" do
    foo = [a: "a", b: "b", c: "c"]
    trans = %{ BitString => fn(x, _d) -> String.to_atom(x) end }
    assert Transform.transform(foo,trans) == [a: :a, b: :b,c: :c]
  end 

  test "convert keyword to nested list" do
    foo = [a: "a", b: "b", c: "c"]
    trans = %{ Keyword => fn(x, _d) -> for {k, v} <- x, into: [], do: [k, v] end }
    assert Transform.transform(foo,trans) == [[:a, "a"], [:b, "b"], [:c, "c"]]
  end 

  test "identity is the default tuple" do 
    assert Transform.transform({1, 2, 3}, %{}) == {1, 2, 3}
  end 

  test "convert tuple elements to atom" do 
    foo = {"a", "b", "c"}
    trans = %{ BitString => fn(x, _d) -> String.to_atom(x) end }
    assert Transform.transform(foo, trans) == {:a, :b, :c}
  end 

  test "convert tuple to list" do 
    foo = {:a, :b, :c}
    trans = %{ Tuple => fn(x, _d) -> Tuple.to_list(x) end }
    assert Transform.transform(foo, trans) == [:a, :b, :c]
  end 

  test "nested tuple to list" do 
    foo = {{:a}, {:b}, {:c}}
    trans = %{ Tuple => fn(x, _d) -> Tuple.to_list(x) end }
    assert Transform.transform(foo, trans) == [[:a], [:b], [:c]]
  end 

  test "identity is the default map" do 
    foo = %{"a" => 1, "b" => 2}
    assert Transform.transform(foo, %{}) == foo
  end 

  test "convert map to keyword list" do
    foo = %{"a" => 1, "b" => 2}
    bar = [a: 1, b: 2]
    to_keyword = fn(m, _d) -> 
      for {k, v} <- m , into: [], do: {String.to_atom(k), v} 
    end
    trans = %{Map => to_keyword}
    assert Transform.transform(foo, trans) == bar
  end 

  test "identity is the default struct" do 
    assert Transform.transform(1..5, %{}) == 1..5
  end 

  test "convert range " do 
    foo = 1..5 
    trans = %{Range => fn(_r, _d) -> %Range{first: 2, last: 5} end}
    assert Transform.transform(1..5, trans) == 2..5
  end 

  test "identity is the default quote do output" do 
    foo = quote do: Enum.map(1..3, fn(x) -> x*x end) |> Enum.sum
    assert Transform.transform(foo, %{}) == foo 
  end 

  test "transform quote do output" do
    foo = quote do: Enum.map(1..3, fn(x) -> x*x end)
    bar = quote do: Enum.map(1..3, fn(y) -> y*y end)
    replace_x = fn(a, _d ) -> 
      case a do 
        :x -> :y 
        atom -> atom
      end 
    end 
    trans = %{ Atom => replace_x }
    assert Transform.transform(foo, trans) == bar
  end 

  test "implement scrub of empty values from map" do
    foo = %{ :a => nil, :b => "", :c => "a"}
    replace_empty = fn(string, _d) -> if( string == "", do: nil , else: string) end 
    replace_nil = fn(map, _depth) ->  for {k, v} <- map, v != nil , into: %{}, do: {k, v} end
    trans = %{ BitString => replace_empty, Map => replace_nil}

    assert Transform.transform(foo, trans) == %{:c => "a"}

  end 

  test "depth check in nested lists" do 
    foo = [[[1,2,3],[2,3]]]
    trans = %{ List => fn(list, depth) -> if ( Enum.count(depth) > 1 ), do: :list_too_deep , else: list end } 
    assert Transform.transform(foo, trans) == [[:list_too_deep,:list_too_deep]]
  end 
end