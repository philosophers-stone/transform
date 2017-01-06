
defmodule PhStTransmogrifyTest do
  use ExUnit.Case

  test "identity is the default atom" do
    assert :foo == elem(PhStTransform.transmogrify(:foo,%{}), 0)
  end

  test "convert to string" do
    potion = %{ Atom => fn(x, p) -> {Atom.to_string(x), p} end}
    assert "foo" == elem(PhStTransform.transmogrify(:foo, potion), 0)
  end

  test "identity is the default string" do
    assert elem(PhStTransform.transmogrify("foo", %{}),0) == "foo"
  end

  test "convert string to atom" do
    potion = %{ BitString => fn(x, p) -> {String.to_atom(x), p} end}
    assert elem(PhStTransform.transmogrify("foo", potion), 0) == :foo
  end

  test "identity is the default Integer" do
    assert 1 == elem(PhStTransform.transmogrify(1,%{}), 0)
  end

  test "convert integer to string" do
    potion = %{ Integer => fn(x, p) -> { Integer.to_string(x), p} end}
    assert elem(PhStTransform.transmogrify(1,potion), 0 ) == "1"
  end

  test "identity is the default Float" do
    assert elem(PhStTransform.transmogrify(1.0, %{}), 0) == 1.0
  end

  test "convert Float to string" do
    potion = %{ Float => fn(x, p) -> {Float.to_string(x), p} end}
    assert elem(PhStTransform.transmogrify(5.0, potion), 0 ) == "5.0"
  end


  test "identity is the default list" do
    assert [1,2,3] == elem(PhStTransform.transmogrify([1,2,3],%{}), 0)
  end

  test "convert list elements to atom" do
    data = ["a", "b", "c"]
    potion = %{ BitString => fn(x, p) -> {String.to_atom(x), p} end }
    assert elem(PhStTransform.transmogrify(data,potion), 0) == [:a, :b, :c]
  end

  test "convert list to tuple" do
    data = [:a, :b, :c]
    potion = %{ List => fn(x, p) -> {List.to_tuple(x), p} end }
    assert elem(PhStTransform.transmogrify(data,potion), 0) == {:a, :b, :c}
  end

  test "nested list to nested tuple" do
    data = [[:a], [:b], [:c]]
    potion = %{ List => fn(x, p) -> {List.to_tuple(x), p} end }
    assert elem(PhStTransform.transmogrify(data,potion), 0) == {{:a}, {:b}, {:c}}
  end

  test "identity is the default keyword" do
    assert elem(PhStTransform.transmogrify([ a: 1, b: 2], %{}), 0) == [a: 1, b: 2]
  end

  test "convert keyword values to atom" do
    data = [a: "a", b: "b", c: "c"]
    potion = %{ BitString => fn(x, p) -> {String.to_atom(x), p} end }
    assert elem(PhStTransform.transmogrify(data,potion), 0) == [a: :a, b: :b,c: :c]
  end

  test "convert keyword to nested list" do
    data = [a: "a", b: "b", c: "c"]
    potion = %{ Keyword => fn(x, p) ->
      new_k = for {k, v} <- x, into: [], do: [k, v]
      {new_k, p}
     end  }
    assert elem(PhStTransform.transmogrify(data,potion), 0) == [[:a, "a"], [:b, "b"], [:c, "c"]]
  end

  test "identity is the default tuple" do
    assert elem(PhStTransform.transmogrify({1, 2, 3}, %{}), 0) == {1, 2, 3}
  end

  test "convert tuple elements to atom" do
    data = {"a", "b", "c"}
    potion = %{ BitString => fn(x, p) -> {String.to_atom(x), p} end }
    assert elem(PhStTransform.transmogrify(data, potion), 0) == {:a, :b, :c}
  end

  test "convert tuple to list" do
    data = {:a, :b, :c}
    potion = %{ Tuple => fn(x, p) -> {Tuple.to_list(x), p} end }
    assert elem(PhStTransform.transmogrify(data, potion), 0) == [:a, :b, :c]
  end

  test "nested tuple to list" do
    data = {{:a}, {:b}, {:c}}
    potion = %{ Tuple => fn(x, p) -> {Tuple.to_list(x), p} end }
    assert elem(PhStTransform.transmogrify(data, potion), 0) == [[:a], [:b], [:c]]
  end

  test "identity is the default map" do
    data = %{"a" => 1, "b" => 2}
    assert elem(PhStTransform.transmogrify(data, %{}), 0) == data
  end

  test "convert map to keyword list" do
    data = %{"a" => 1, "b" => 2}
    bar = [a: 1, b: 2]
    to_keyword = fn(m, p) ->
      kp = for {k, v} <- m , into: [], do: {String.to_atom(k), v}
      {kp, p}
    end
    potion = %{Map => to_keyword}
    assert elem(PhStTransform.transmogrify(data, potion), 0) == bar
  end

  test "identity is the default struct" do
    assert elem(PhStTransform.transmogrify(1..5, %{}), 0) == 1..5
  end

  test "convert range " do
    potion = %{Range => fn(_r, p) -> {%Range{first: 2, last: 5}, p} end}
    assert elem(PhStTransform.transmogrify(1..5, potion), 0) == 2..5
  end

  test "identity is the default quote do output" do
    data = quote do: Enum.map(1..3, fn(x) -> x*x end) |> Enum.sum
    assert elem(PhStTransform.transmogrify(data, %{}), 0) == data
  end

  test "transmogrify quote do output" do
    data = quote do: Enum.map(1..3, fn(x) -> x*x end)
    data_transmogrify = quote do: Enum.map(1..3, fn(y) -> y*y end)
    replace_x = fn(a, p, _d) ->
      case a do
        :x -> {:y, p}
        atom -> {atom, p}
      end
    end
    potion = %{ Atom => replace_x }
    assert elem(PhStTransform.transmogrify(data, potion), 0) == data_transmogrify
  end

  test "implement scrub of empty values from map" do
    data = %{ :a => nil, :b => "", :c => "a"}

    replace_empty = fn(string, p) ->
      str = if( string == "", do: nil , else: string)
      {str, p}
    end

    replace_nil = fn(map, p ) ->
      new_map = for {k, v} <- map, v != nil , into: %{}, do: {k, v}
      {new_map, p}
    end

    potion = %{ BitString => replace_empty, Map => replace_nil}
    assert elem(PhStTransform.transmogrify(data, potion), 0) == %{:c => "a"}
  end

  test "depth check in nested lists" do
    data = [[[1,2,3],[2,3]]]
    potion = %{ List => fn(list, p, depth) ->
      new_item = if ( Enum.count(depth) > 1 ), do: :list_too_deep , else: list
      {new_item, p}
    end }
    assert elem(PhStTransform.transmogrify(data, potion), 0) == [[:list_too_deep,:list_too_deep]]
  end

  test "struct transmogrify works when Any is not the default" do
    potion = %{Range => fn(_r, p, _d) ->{ %Range{first: 2, last: 5}, p} end,
               Any => fn(x, p, _d) -> if(is_map(x), do: {inspect(x), p}, else: {x, p}) end }
    assert elem(PhStTransform.transmogrify(1..5, potion), 0) == 2..5
  end

  test "csv transmogrify example" do
    data = ["name,rank,serial_number", "bob,private,1", "fred,major,2"]
    test_map_list = [%{"serial_number" => "1", "name" => "bob", "rank" => "private"}, %{"serial_number" => "2", "name" => "fred", "rank" => "major"}]

    csv_potion = %{ BitString => fn(str, potion) ->
                                      keys = String.split(str, ",")
                                      new_potion = Map.put(potion, BitString, fn(str, potion) ->
                                       { String.split(str,",")
                                        |> Enum.zip(keys)
                                        |> Enum.reduce( %{}, fn(tuple, map) ->
                                          {v, k} = tuple
                                          Map.put(map,k,v) end),
                                        potion }
                                        end )
                                      {keys, new_potion}
      end }

     assert elem(PhStTransform.transmogrify(data, csv_potion), 0) == [["name","rank","serial_number"] | test_map_list ]
  end

end