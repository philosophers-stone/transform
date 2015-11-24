defprotocol Transform do
  @moduledoc """
  The `Transform` protocol will convert any Elixir data structure
  using a given transform into a new data structure. 

  The `transform/3` function takes the data structure and 
  a map of transformation functions and a depth list. It will
  then does a depth-first recursion through the structure, 
  applying the tranformation functions for all 
  data types found in the data structure. 

  The transform map has data types as keys and 
  anonymous functions as values. The anonymous
  functions have the data item and recursion depth
  as inputs and can return anything. 

  transformer = %{ Atom => fn(atom, _depth) -> atom end }
  """

  # Handle structs in Any
  @fallback_to_any true

  def transform(structure, function_map, depth \\ [])

  # Some other ideas, depth could be a list of transformations rather
  # than a simple count. i.e. [ List, List, Atom ]
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



