# PhStTransform

**A Protocol Implementation for transforming arbitrary Elixir data Structures**

## Documentation

The `PhStTransform` protocol will convert any Elixir data structure
using a given transform map into a new data structure.

The `transform/3` function takes the data structure and
a map of transformation functions and a depth level. It
then does a depth-first recursion through the structure,
applying the tranformation functions for all
data types found in the data structure.

The transform map has data types as keys and anonymous functions
as values. The anonymous functions have the data item and recursion
depth list as inputs and can return anything. These maps of types
and functions are referred to as potions.

## Examples

    iex> potion = %{ Atom => fn(atom) -> Atom.to_string(atom) end }
    iex> data = %{:a => [a: :a], :b => {:c, :d}, "f" => [:e, :g]}
    iex> PhStTransform.transform(data, potion)
    %{:a => [a: "a"], :b => {"c", "d"}, "f" => ["e", "g"]}

## Using PhStTransform

The potion map should have Elixir Data types as keys and anonymous functions
of either `fn(x)` or `fn(x, depth)` arity. You can supply nearly any kind of map
as an argument however, since the `PhStTransform.Potion.brew`function will strip
out any invalid values. The valid keys are all of the standard Protocol types:

    [Atom, Integer, Float, BitString, Regexp, PID, Function, Reference, Port, Tuple, List, Map]

plus `Keyword` and the name of any defined Structs (e.g. `Range`).

There is also the special type `Any`, this is the default function applied
when there is no function for the type listed in the potion. By default
this is set to the identity function `fn(x, _d) -> x end`, but can be overridden
in the initial map.

The depth argument should always be left at the default value when using
this protocol. The anonymous functions in the potion map can use
the depth list to know which kind of data structure contains the current
data type.

For example: Capitalize all strings in the `UserName` struct, normalize all other strings.

    user_potion = %{ BitString =>
      fn(str, depth) -> if(List.first(depth) == UserName , do: String.capitalize(str) , else: String.downcase(str)) end}

    PhStTransform.transform(data, user_potion)

## Limitations

Clearly there are some transformations that would be difficult or impossible
to duplicate in a single potion. The tranformations can be easily composed,
but this has a performance cost in that each `tranform` iterates through
the entire data structure.

Also, since transforms are implemented as a Protocol, the transforms will be
relatively slow during development since the Protocol is not consolidated
for development compilations. Protocol consolidation will improve the speed
in production, but like any general purpose tool, this module emphasizes
utility over performance.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add transform to your list of dependencies in `mix.exs`:

        def deps do
          [{:transform, "~> 0.0.1"}]
        end

  2. Ensure transform is started before your application:

        def application do
          [applications: [:phst_transform]]
        end
