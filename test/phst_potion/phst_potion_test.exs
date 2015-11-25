Code.require_file "../test_helper.exs", __DIR__

defmodule PhStTransform.PotionTest do
  use ExUnit.Case, async: true

  test "brew returns a map with only atoms as keys" do
  	potion = %{ "bar" => 1, Atom => fn(x) -> x end, String => &String.upcase/1 }
  	assert Map.keys(PhStTransform.Potion.brew(potion,[])) == [Any, Atom, String]
  end

  test "brew returns a map with only functions as values" do
  	map = %{ "bar" => 1, Atom => 2, String => fn(x, _d) -> x end}
  	potion = PhStTransform.Potion.brew(map,[])
    for {_type, func} <- potion , do: assert is_function(func)
  end

  test "brew simply returns the map when depth is not []" do
    potion = %{ "bar" => 1, Atom => 2, String => fn(x, _d) -> x end}
  	assert PhStTransform.Potion.brew(potion,[List]) == potion
  end

  test "brew raises an ArgumentError when the first arg is not a map" do
  	assert_raise ArgumentError, fn -> PhStTransform.Potion.brew([a: &String.upcase/1],[List]) end
  end

  test "brew raises an ArgumentError when a function has arity > 2 " do
  	potion = %{ Atom => fn(a,b,c) -> {a,b,c} end}
    assert_raise ArgumentError, fn -> PhStTransform.Potion.brew(potion,[]) end
  end

  test "distill returns a function" do
    map = %{ "bar" => 1, Atom => fn(x) -> x end, String => &String.upcase/1 }
    potion =  PhStTransform.Potion.brew(map,[])
    std_types = [Atom, Integer, Float, BitString, Regexp, PID, Function, Reference, Port, Tuple, List, Map, Keyword, Range]
    for type <- std_types, do: assert is_function(PhStTransform.Potion.distill(type, potion))
  end
end