# Transform

**A Protocol Implementation for Transforming arbitrary Elixir data Structures**

## Documentation

The `Transform` protocol will convert any Elixir data structure
using a given transform map into a new data structure.

The `transform/3` function takes the data structure and
a map of transformation functions and a depth level. It
then does a depth-first recursion through the structure,
applying the tranformation functions for all
data types found in the data structure.

The transform map has data types as keys and
anonymous functions as values. The anonymous
functions have the data item and recursion depth list
as inputs and can return anything.

## Examples

	  iex> potion = %{ Atom => fn(atom) -> Atom.to_string(atom) end }
    iex> data = %{:a => [a: :a], :b => {:c, :d}, "f" => [:e, :g]}
	  iex> Transform.transform(data, potion)
	  %{:a => [a: "a"], :b => {"c", "d"}, "f" => ["e", "g"]}

## Using Transform

The potion map should have Elixir Data types as keys and anonymous functions
of either fn(x) or fn(x, depth) arity. You can supply nearly any kind of map
as an argument however, since the `Transform.Potion.brew`function will strip
out any invalid values. The valid keys are all of the standard Protocol types:

    [Atom, Integer, Float, BitString, Regexp, PID, Function, Reference, Port, Tuple, List, Map]

plus `Keyword` and the name of any defined Structs (e.g. `Range`)

The depth argument should always be left at the default value when using
this protocol. For the anonymous functions in the potion map, they can use
the depth list to know which kind of data structure contains the current
data type.

For example: Capitalize all strings in the `UserName` struct, normalize all other strings.

    user_potion = %{ BitString =>
      fn(str, depth) -> if(List.first(depth) == UserName , do: String.capitalize(str) , else: String.downcase(str)) end}

    Transform.transform(data, user_potion)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add transform to your list of dependencies in `mix.exs`:

        def deps do
          [{:transform, "~> 0.0.1"}]
        end

  2. Ensure transform is started before your application:

        def application do
          [applications: [:transform]]
        end
