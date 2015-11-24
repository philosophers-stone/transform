Code.require_file "../test_helper.exs", __DIR__

defmodule Transform.PotionTest do
  use ExUnit.Case, async: true

  test "brew returns a map with only atoms as keys" do
  	foo = %{ "bar" => 1, Atom => fn(x) -> x end, String => &String.upcase/1 }
  	assert Map.keys(Transform.Potion.brew(foo,[])) == [Atom, String]
  end

  test "brew returns a map with only functions as values" do
  	foo = %{ "bar" => 1, Atom => 2, String => fn(x, _d) -> x end}
  	assert Transform.Potion.brew(foo,[]) == %{ String => fn(x, _d) -> x end }
  end 

  test "brew simply returns the map when depth is not []" do
    foo = %{ "bar" => 1, Atom => 2, String => fn(x, _d) -> x end}
  	assert Transform.Potion.brew(foo,[List]) == foo
  end 

  test "brew raises an ArgumentError when the first arg is not a map" do
  	assert_raise ArgumentError, fn -> Transform.Potion.brew([a: &String.upcase/1],[List]) end
  end

  test "brew raises an ArgumentError when a function has arity > 2 " do
  	foo = %{ Atom => fn(a,b,c) -> {a,b,c} end}
    assert_raise ArgumentError, fn -> Transform.Potion.brew(foo,[]) end
  end 
end 