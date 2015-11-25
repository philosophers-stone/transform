defprotocol PhStTransform do
  @moduledoc """
  The `PhStTransform` protocol will convert any Elixir data structure
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

  ## Example: Convert all atoms to strings

      atom_to_string_potion = %{ Atom => fn(atom) -> Atom.to_string(atom) end }
      PhStTransform.transform(data, atom_to_string_potion)

  The potion map should have Elixir Data types as keys and anonymous functions
  of either `fn(x)` or `fn(x, depth)` arity. You can supply nearly any kind of map
  as an argument however, since the `PhStTransform.Potion.brew`function will strip
  out any invalid values. The valid keys are all of the standard Protocol types:

      [Atom, Integer, Float, BitString, Regexp, PID, Function, Reference, Port, Tuple, List, Map]

  plus `Keyword` and the name of any defined Structs (e.g. `Range`)

  There is also the special type `Any`, this is the default function applied
  when there is no function for the type listed in the potion. By default
  this is set to the identity function `fn(x, _d) -> x end`, but can be overridden
  in the initial map.

  The depth argument should always be left at the default value when using
  this protocol. For the anonymous functions in the potion map, they can use
  the depth list to know which kind of data structure contains the current
  data type.

  ## Example: Capitalize all strings in the UserName struct, normalize all other strings.

      user_potion = %{ BitString => fn(str, depth) ->
        if(List.first(depth) == UserName), do: String.capitalize(str), else: String.downcase(str)) end}

      PhStTransform.transform(data, user_potion)

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
      iex> PhStTransform.transform([[:a], :b, {:c, :e}], atom_to_string_potion)
      [["a"], "b", {"c", "e"}]

  """
  def transform(data_structure, function_map, depth \\ [])

end

defimpl PhStTransform, for: Atom do

  def transform(atom, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Atom, potion)
    trans.(atom, depth)
  end

end

defimpl PhStTransform, for: BitString do

  def transform(bitstring, function_map, depth \\ []) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(BitString, potion)
    trans.(bitstring, depth)
  end

end

defimpl PhStTransform, for: Integer do

  def transform(integer, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Integer, potion)
    trans.(integer, depth)
  end

end

defimpl PhStTransform, for: Float do

  def transform(float, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Float, potion)
    trans.(float, depth)
  end

end

defimpl PhStTransform, for: List do

  def transform(list, function_map, depth \\0 ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    case Keyword.keyword?(list) do
      true -> keyword_transform(list, potion, depth)
      _ -> list_transform(list, potion, depth)
    end
  end

  defp list_transform(list, potion, depth) do
    new_list =  Enum.map(list, fn(l) -> PhStTransform.transform(l, potion, [List | depth]) end)
    trans =  PhStTransform.Potion.distill(List, potion)
    trans.(new_list, depth)
  end

  defp keyword_transform(klist, potion, depth) do
    new_klist = Enum.map(klist, fn({key, value}) -> {key, PhStTransform.transform(value, potion,[Keyword | depth]) } end)
    trans = PhStTransform.Potion.distill(Keyword, potion)
    trans.(new_klist, depth)
  end

end

defimpl PhStTransform, for: Tuple do

  def transform(tuple, function_map, depth \\ []) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    new_tuple = tuple
      |> Tuple.to_list
      |> Enum.map(fn(x) -> PhStTransform.transform(x, potion, [Tuple | depth] ) end)
      |> Enum.to_list
      |> List.to_tuple
    trans = PhStTransform.Potion.distill(Tuple, potion)
    trans.(new_tuple, depth)
  end

end

defimpl PhStTransform, for: Map do

  def transform(map, function_map, depth \\0 ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    new_map =  for {key, val} <- map, into: %{}, do: {key, PhStTransform.transform(val, potion, [Map | depth])}
    trans = PhStTransform.Potion.distill(Map, potion)
    trans.(new_map, depth)
  end

end

defimpl PhStTransform, for: Regex do

  def transform(regex, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Regex, potion)
    trans.(regex, depth)
  end

end

defimpl PhStTransform, for: Function do

  def transform(function, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Function, potion)
    trans.(function, depth)
  end

end

defimpl PhStTransform, for: PID do

  def transform(pid, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(PID, potion)
    trans.(pid, depth)
  end

end

defimpl PhStTransform, for: Port do

  def transform(port, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Port, potion)
    trans.(port, depth)
  end

end

defimpl PhStTransform, for: Reference do

  def transform(reference, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Reference, potion)
    trans.(reference, depth)
  end

end

defimpl PhStTransform, for: Any do

  def transform(%{__struct__: struct_name} = map, function_map, depth \\ []) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    try do
      struct_name.__struct__
    rescue
      _ -> PhStTransform.Map.transform(map, potion, depth)
    else
      default_struct ->
        if :maps.keys(default_struct) == :maps.keys(map) do
          data = Map.from_struct(map)
          # remove any Map transforms from the function map
          new_potion = Map.delete(potion, Map)
          new_data = PhStTransform.Map.transform(data, new_potion, [struct_name | depth])
          new_struct = struct(struct_name, new_data)

          trans = PhStTransform.Potion.distill(struct_name, potion)
          trans.(new_struct, depth)
        else
          PhStTransform.Map.transform(map, potion, depth)
        end
    end

  end

end



