defprotocol Transform do
  @moduledoc """
  The `Transform` protocol will convert any Elixir data structure
  using a given transform into a new data structure. 

  The `transform/3` function takes the data structure and 
  a map of transformation functions and a depth level. It will
  then does a depth-first recursion through the structure, 
  applying the tranformation functions for all 
  data types found in the data structure. 

  The transform map has data types as keys and 
  anonymous functions as values. The anonymous
  functions have the data item and recursion depth
  as inputs and can return anything. 

  transformer = %{ Atom => fn(atom, depth) -> atom end }
  """

  # Handle structs in Any
  @fallback_to_any true

  def transform(structure, function_map, depth \\ 0)

  # Some other ideas, depth could be a list of transformations rather
  # than a simple count. i.e. [ List, List, Atom ]
end

defimpl Transform, for: Atom do 

  def transform(atom, function_map, depth \\ 0 ) do 
    trans = Map.get(function_map, Atom, fn(x, _d) -> x end )
    trans.(atom, depth)
  end 

end 

defimpl Transform, for: BitString do

  def transform(bitstring, function_map, depth \\ 0) do 
    trans = Map.get(function_map, BitString, fn(x, _d) -> x end )
    trans.(bitstring, depth)
  end 

end 

defimpl Transform, for: Integer do

  def transform(integer, function_map, depth \\ 0 ) do 
    trans = Map.get(function_map, Integer, fn(x, _d) -> x end )
    trans.(integer, depth)
  end 

end 

defimpl Transform, for: Float do

  def transform(float, function_map, depth \\ 0 ) do 
    trans = Map.get(function_map, Float, fn(x, _d) -> x end )
    trans.(float, depth)
  end 

end 

defimpl Transform, for: List do

  # Could use Keyword.keyword? and Keyword as data value
  def transform(list, function_map, depth \\0 ) do 
    case Keyword.keyword?(list) do 
      true -> keyword_transform(list, function_map, depth)
      _ -> list_transform(list, function_map, depth)
    end
  end 

  defp list_transform(list, function_map, depth) do
    new_list =  Enum.map(list, fn(l) -> Transform.transform(l, function_map, depth + 1) end)
    trans =  Map.get(function_map, List, fn(x, _d) -> x end )
    trans.(new_list, depth)
  end

  defp keyword_transform(klist, function_map, depth) do
    new_klist = Enum.map(klist, fn({key, value}) -> {key, Transform.transform(value, function_map, depth + 1) } end)
    trans = Map.get(function_map, Keyword, fn(x, _d) -> x end )
    trans.(new_klist, depth)
  end 

end 

defimpl Transform, for: Tuple do

  def transform(tuple, function_map, depth \\ 0) do 
    new_tuple = tuple 
      |> Tuple.to_list
      |> Enum.map(fn(x) -> Transform.transform(x, function_map, depth + 1 ) end)
      |> Enum.to_list
      |> List.to_tuple
    trans = Map.get(function_map, Tuple, fn(x, _d) -> x end )
    trans.(new_tuple, depth)
  end 

end 

defimpl Transform, for: Map do

  def transform(map, function_map, depth \\0 ) do 
    new_Map =  for {key, val} <- map, into: %{}, do: {key, Transform.transform(val, function_map, depth + 1 )}
    trans = Map.get(function_map, Map, fn(x, _d) -> x end )
    trans.(new_Map, depth)
  end 

end 

defimpl Transform, for: Regex do

  def transform(regex, function_map, depth \\ 0 ) do 
    trans = Map.get(function_map, Regex, fn(x, _d) -> x end )
    trans.(regex, depth)
  end 

end

defimpl Transform, for: Function do

  def transform(function, function_map, depth \\ 0 ) do 
    trans = Map.get(function_map, Function, fn(x, _d) -> x end )
    trans.(function, depth)
  end 

end

defimpl Transform, for: PID do

  def transform(pid, function_map, depth \\ 0 ) do 
    trans = Map.get(function_map, PID, fn(x, _d) -> x end )
    trans.(pid, depth)
  end 

end

defimpl Transform, for: Port do

  def transform(port, function_map, depth \\ 0 ) do 
    trans = Map.get(function_map, Port, fn(x, _d) -> x end )
    trans.(port, depth)
  end 

end 

defimpl Transform, for: Reference do

  def transform(reference, function_map, depth \\ 0 ) do 
    trans = Map.get(function_map, Reference, fn(x, _d) -> x end )
    trans.(reference, depth)
  end 

end 

defimpl Transform, for: Any do

  def transform(%{__struct__: struct_name} = map, function_map, depth \\ 0) do
    try do 
      struct_name.__struct__
    rescue
      _ -> Transform.Map.transform(map, function_map, depth)
    else 
      default_struct ->
        if :maps.keys(default_struct) == :maps.keys(map) do
          data = Map.from_struct(map)
          # Should we remove any Map transforms from the function map? 
          new_function_map = Map.delete(function_map, Map)
          new_data = Transform.Map.transform(data, new_function_map, depth )
          new_struct = struct(struct_name, new_data)

          trans = Map.get(function_map, struct_name, fn(x, _d) -> x end)
          trans.(new_struct, depth)
        else
          Transform.Map.transform(map, function_map, depth)
        end
    end 

  end 

end 



