
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
end