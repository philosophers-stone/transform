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
functions have the data item and recursion depth
as inputs and can return anything. 

## Examples

	iex> transformer = %{ Atom => fn(atom, _depth) -> Atom.to_string(atom) end }
	iex> Transform.transform([:a, :b, :c], transformer)
	["a","b","c"]



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
