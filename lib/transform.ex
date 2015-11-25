defprotocol Transform do
  @moduledoc """
  The `Transform` protocol will convert any Elixir data structure
  using a given transform into a new data structure.

  The `transform/3` function takes the data structure and
  a map of transformation functions and a depth list. It
  then does a depth-first recursion through the structure,
  applying the tranformation functions for all
  data types found in the data structure.

  The transform map has data types as keys and anonymous functions
  as values. The anonymous functions have the data item and
  optionally a recursion depth list as inputs and can
  return anything. These maps of transform functions
  are refered to as potions.

  For example: Convert all atoms to strings

  atom_to_string_potion = %{ Atom => fn(atom) -> Atom.to_string(atom) end }
  Transform.transform(data, atom_to_string_potion)

  The potion map should have Elixir Data types as keys and anonymous functions
  of either fn(x) or fn(x, depth) arity. You can supply nearly any kind of map
  as an argument however, since the `Transform.Potion.brew`function will strip
  out any invalid values. The valid keys are all of the standard Protocol types:

  [Atom, Integer, Float, BitString, Regexp, PID, Function, Reference, Port, Tuple, List, Map]

  plus `Keyword` and the name of any defined Structs (e.g. Range)

  The depth argument should always be left at the default value when using
  this protocol. For the anonymous functions in the potion map, they can use
  the depth list to know which kind of data structure contains the current
  data type.

  For example: Capitalize all strings in the UserName struct, normalize all other strings.

  user_potion = %{ BitString => fn(str, depth) ->
    if(List.first(depth) == UserName), do: String.capitalize(str), else: String.downcase(str)) end}

  Transform.transform(data, user_potion)

  """

  # Handle structs in Any
  @fallback_to_any true

  @doc """
  uses the given function_map to transform any Elixir data structure.

  `function_map` should contain keys that correspond to the data types
  to be transformed. Each key must map to a function that takes that data
  type and optionally the depth list as arguments.

  `depth` should always be left at the default value since it is meant for
  internal recursion.

  ## Examples

      iex> atom_to_string_potion = %{ Atom => fn(atom) -> Atom.to_string(atom) end }
      iex> Transform.transform([[:a], :b, {:c, :e}], atom_to_string_potion)
      [["a"], "b", {"c", "e"}]

  """
  def transform(data_structure, function_map, depth \\ [])

end

defimpl Transform, for: Atom do

  def transform(atom, function_map, depth \\ [] ) do
    potion = Transform.Potion.brew(function_map, depth)
    trans = Map.get(potion, Atom, fn(x, _d) -> x end )
    trans.(atom, depth)
  end

end

defimpl Transform, for: BitString do

  def transform(bitstring, function_map, depth \\ []) do
    potion = Transform.Potion.brew(function_map, depth)
    trans = Map.get(potion, BitString, fn(x, _d) -> x end )
    trans.(bitstring, depth)
  end

end

defimpl Transform, for: Integer do

  def transform(integer, function_map, depth \\ [] ) do
    potion = Transform.Potion.brew(function_map, depth)
    trans = Map.get(potion, Integer, fn(x, _d) -> x end )
    trans.(integer, depth)
  end

end

defimpl Transform, for: Float do

  def transform(float, function_map, depth \\ [] ) do
    potion = Transform.Potion.brew(function_map, depth)
    trans = Map.get(potion, Float, fn(x, _d) -> x end )
    trans.(float, depth)
  end

end

defimpl Transform, for: List do

  def transform(list, function_map, depth \\0 ) do
    potion = Transform.Potion.brew(function_map, depth)
    case Keyword.keyword?(list) do
      true -> keyword_transform(list, potion, depth)
      _ -> list_transform(list, potion, depth)
    end
  end

  defp list_transform(list, potion, depth) do
    new_list =  Enum.map(list, fn(l) -> Transform.transform(l, potion, [List | depth]) end)
    trans =  Map.get(potion, List, fn(x, _d) -> x end )
    trans.(new_list, depth)
  end

  defp keyword_transform(klist, potion, depth) do
    new_klist = Enum.map(klist, fn({key, value}) -> {key, Transform.transform(value, potion,[Keyword | depth]) } end)
    trans = Map.get(potion, Keyword, fn(x, _d) -> x end )
    trans.(new_klist, depth)
  end

end

defimpl Transform, for: Tuple do

  def transform(tuple, function_map, depth \\ []) do
    potion = Transform.Potion.brew(function_map, depth)
    new_tuple = tuple
      |> Tuple.to_list
      |> Enum.map(fn(x) -> Transform.transform(x, potion, [Tuple | depth] ) end)
      |> Enum.to_list
      |> List.to_tuple
    trans = Map.get(potion, Tuple, fn(x, _d) -> x end )
    trans.(new_tuple, depth)
  end

end

defimpl Transform, for: Map do

  def transform(map, function_map, depth \\0 ) do
    potion = Transform.Potion.brew(function_map, depth)
    new_map =  for {key, val} <- map, into: %{}, do: {key, Transform.transform(val, potion, [Map | depth])}
    trans = Map.get(potion, Map, fn(x, _d) -> x end )
    trans.(new_map, depth)
  end

end

defimpl Transform, for: Regex do

  def transform(regex, function_map, depth \\ [] ) do
    potion = Transform.Potion.brew(function_map, depth)
    trans = Map.get(potion, Regex, fn(x, _d) -> x end )
    trans.(regex, depth)
  end

end

defimpl Transform, for: Function do

  def transform(function, function_map, depth \\ [] ) do
    potion = Transform.Potion.brew(function_map, depth)
    trans = Map.get(potion, Function, fn(x, _d) -> x end )
    trans.(function, depth)
  end

end

defimpl Transform, for: PID do

  def transform(pid, function_map, depth \\ [] ) do
    potion = Transform.Potion.brew(function_map, depth)
    trans = Map.get(potion, PID, fn(x, _d) -> x end )
    trans.(pid, depth)
  end

end

defimpl Transform, for: Port do

  def transform(port, function_map, depth \\ [] ) do
    potion = Transform.Potion.brew(function_map, depth)
    trans = Map.get(potion, Port, fn(x, _d) -> x end )
    trans.(port, depth)
  end

end

defimpl Transform, for: Reference do

  def transform(reference, function_map, depth \\ [] ) do
    potion = Transform.Potion.brew(function_map, depth)
    trans = Map.get(potion, Reference, fn(x, _d) -> x end )
    trans.(reference, depth)
  end

end

defimpl Transform, for: Any do

  def transform(%{__struct__: struct_name} = map, function_map, depth \\ []) do
    potion = Transform.Potion.brew(function_map, depth)
    try do
      struct_name.__struct__
    rescue
      _ -> Transform.Map.transform(map, potion, depth)
    else
      default_struct ->
        if :maps.keys(default_struct) == :maps.keys(map) do
          data = Map.from_struct(map)
          # remove any Map transforms from the function map
          new_potion = Map.delete(potion, Map)
          new_data = Transform.Map.transform(data, new_potion, [struct_name | depth])
          new_struct = struct(struct_name, new_data)

          trans = Map.get(potion, struct_name, fn(x, _d) -> x end)
          trans.(new_struct, depth)
        else
          Transform.Map.transform(map, potion, depth)
        end
    end

  end

end



