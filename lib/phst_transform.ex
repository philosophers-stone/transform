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

  The `transmogrify/3` function is similar except that it allows
  the functions to modify the potion map as the tranform is
  in progress and it returns a tuple consisting of the
  transformed data and potion.

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


  ## Example: Parse a list of strings input from a CSV file, into a list of maps.

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

       csv_strings = File.stream!("file.csv") |> Enum.into([])
       {[keys | maps ], new_potion } = PhStTranform.transmogrify(csv_strings, csv_potion)

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

  @doc """
  Works similarly to transform, but returns a tuple consisting
  of {result, potion} allowing self modifying potions.

  ## Examples

      iex> atom_first = %{ Atom => fn(atom, potion) ->
             old = atom
            { atom, Map.put(potion, Atom, fn(atom, potion) ->
              {old, potion} end )} end }
      iex> PhStTransform.transmorgrify([:a, :b, :c, :d], atom_first)
      {[:a, :a, :a, :a], %{Atom => #Function<12.54118792/2 in :erl_eval.expr/5>} }
  """
  def transmogrify(data_structure, function_map, depth \\ [])

end

defimpl PhStTransform, for: Atom do

  def transform(atom, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Atom, potion)
    trans.(atom, depth)
  end

  def transmogrify(atom, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    trans = PhStTransform.Potion.distill(Atom, potion)
    trans.(atom, potion, depth)
  end
end

defimpl PhStTransform, for: BitString do

  def transform(bitstring, function_map, depth \\ []) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(BitString, potion)
    trans.(bitstring, depth)
  end

  def transmogrify(bitstring, function_map, depth \\ []) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    trans = PhStTransform.Potion.distill(BitString, potion)
    trans.(bitstring, potion, depth)
  end

end

defimpl PhStTransform, for: Integer do

  def transform(integer, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Integer, potion)
    trans.(integer, depth)
  end

  def transmogrify(integer, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    trans = PhStTransform.Potion.distill(Integer, potion)
    trans.(integer, potion, depth)
  end
end

defimpl PhStTransform, for: Float do

  def transform(float, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Float, potion)
    trans.(float, depth)
  end

  def transmogrify(float, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    trans = PhStTransform.Potion.distill(Float, potion)
    trans.(float, potion, depth)
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

  def transmogrify(list, function_map, depth \\0 ) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    case Keyword.keyword?(list) do
      true -> keyword_transmogrify(list, potion, depth)
      _ -> list_transmogrify(list, potion, depth)
    end
  end

  defp list_transmogrify(list, potion, depth) do
    new_depth = [List | depth]
    {new_list, next_potion} = Enum.reduce(list, {[], potion}, fn(item, {l, potion})->
      {new_item, new_potion} = PhStTransform.transmogrify(item, potion, new_depth)
      {[new_item | l ], new_potion} end)


    trans =  PhStTransform.Potion.distill(List, next_potion)
    trans.(:lists.reverse(new_list), next_potion, depth)
  end

  defp keyword_transmogrify(klist, potion, depth) do
    new_depth = [Keyword | depth]
    {new_klist, next_potion } = Enum.reduce(klist, {[], potion}, fn({key, value}, {kl, potion}) ->
      {new_value, new_potion} = PhStTransform.transmogrify(value, potion, new_depth)
      {[{key, new_value}| kl], new_potion} end)

    trans = PhStTransform.Potion.distill(Keyword, next_potion)
    trans.(:lists.reverse(new_klist), next_potion, depth)
  end


end

defimpl PhStTransform, for: Tuple do

  def transform(tuple, function_map, depth \\ []) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    new_tuple = tuple
      |> Tuple.to_list
      |> Enum.map(fn(x) -> PhStTransform.transform(x, potion, [Tuple | depth] ) end)
      |> List.to_tuple
    trans = PhStTransform.Potion.distill(Tuple, potion)
    trans.(new_tuple, depth)
  end

  def transmogrify(tuple, function_map, depth \\[]) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    new_depth = [Tuple| depth]
    {new_tuple_list, next_potion} = tuple
      |> Tuple.to_list
      |> Enum.reduce({[], potion}, fn(item, {l, potion})->
        {new_item, new_potion} = PhStTransform.transmogrify(item, potion, new_depth)
        {[new_item | l ], new_potion} end)

    new_tuple = List.to_tuple(:lists.reverse(new_tuple_list))
    trans = PhStTransform.Potion.distill(Tuple, potion)
    trans.(new_tuple, next_potion, depth)
  end

end

defimpl PhStTransform, for: Map do

  def transform(map, function_map, depth \\0 ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    new_map =  for {key, val} <- map, into: %{}, do: {key, PhStTransform.transform(val, potion, [Map | depth])}
    trans = PhStTransform.Potion.distill(Map, potion)
    trans.(new_map, depth)
  end

  def transmogrify(map, function_map, depth \\0 ) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    new_depth = [Map | depth]

    {new_map, next_potion} = Enum.reduce(map, {%{}, potion}, fn({key, value}, {bmap, potion}) ->
      {new_value, new_potion} = PhStTransform.transmogrify(value, potion, new_depth)
      {Map.put(bmap,key,new_value), new_potion} end)

    trans = PhStTransform.Potion.distill(Map, potion)
    trans.(new_map, next_potion, depth)
  end

end

defimpl PhStTransform, for: Regex do

  def transform(regex, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Regex, potion)
    trans.(regex, depth)
  end

  def transmogrify(regex, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    trans = PhStTransform.Potion.distill(Regex, potion)
    trans.(regex, potion, depth)
  end
end

defimpl PhStTransform, for: Function do

  def transform(function, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Function, potion)
    trans.(function, depth)
  end

  def transmogrify(function, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    trans = PhStTransform.Potion.distill(Function, potion)
    trans.(function, potion, depth)
  end

end

defimpl PhStTransform, for: PID do

  def transform(pid, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(PID, potion)
    trans.(pid, depth)
  end

  def transmogrify(pid, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    trans = PhStTransform.Potion.distill(PID, potion)
    trans.(pid, potion, depth)
  end

end

defimpl PhStTransform, for: Port do

  def transform(port, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Port, potion)
    trans.(port, depth)
  end

  def transmogrify(port, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    trans = PhStTransform.Potion.distill(Port, potion)
    trans.(port, potion, depth)
  end

end

defimpl PhStTransform, for: Reference do

  def transform(reference, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.brew(function_map, depth)
    trans = PhStTransform.Potion.distill(Reference, potion)
    trans.(reference, depth)
  end

  def transmogrify(reference, function_map, depth \\ [] ) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    trans = PhStTransform.Potion.distill(Reference, potion)
    trans.(reference, potion, depth)
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
          # replace any Map transforms from the potion with the identity map
          new_potion = Map.put(potion, Map, fn(x, _d) -> x end)
          new_data = PhStTransform.Map.transform(data, new_potion, [struct_name | depth])
          new_struct = struct(struct_name, new_data)

          trans = PhStTransform.Potion.distill(struct_name, potion)
          trans.(new_struct, depth)
        else
          PhStTransform.Map.transform(map, potion, depth)
        end
    end
  end

  def transmogrify(%{__struct__: struct_name} = map, function_map, depth \\ []) do
    potion = PhStTransform.Potion.concoct(function_map, depth)
    try do
      struct_name.__struct__
    rescue
      _ -> PhStTransform.Map.transmogrify(map, potion, depth)
    else
      default_struct ->
        if :maps.keys(default_struct) == :maps.keys(map) do
          data = Map.from_struct(map)
          # replace any Map transforms from the potion with the identity map
          new_potion = Map.put(potion, Map, fn(x, p, _d) -> {x, p} end)
          { new_data, next_potion } = PhStTransform.Map.transmogrify(data, new_potion, [struct_name | depth])
          new_struct = struct(struct_name, new_data)

          trans = PhStTransform.Potion.distill(struct_name, potion)
          trans.(new_struct, next_potion, depth)
        else
          PhStTransform.Map.transmogrify(map, potion, depth)
        end
    end
  end

end



