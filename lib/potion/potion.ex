defmodule Transform.Potion do
  @moduledoc """
  This module provides some helper methods for creating maps that
  work with the `Transform` Protocol.

  The methods in this module that are public are not intended to
  be used outside of writing a implementation of the `Transform` Protocol.
  """

  @doc """
  brew validates and prepares a map to be used with the `Transform` Protocol.

  Every key in the map that is an `Atom` and that starts with `Elixir.` must
  have a function as a value. That function must have either arity 1 or 2
  and if it is arity 1, it must be wrapped with arity 2 closure.

  This validation only occurs at the top of the transformation tree when
  the depth list is empty.
  """
  def brew(map, []) when is_map(map) do
    potion = for {type, func} <- map, validate(type, func) , into: %{} , do: {type, wrap(func, type)}
    Map.put_new(potion, Any, fn(x, _d) -> x end)
  end

  def brew(map, depth) when is_map(map) and is_list(depth) do
    map
  end

  def brew(map, _depth) do
    raise ArgumentError, "#{inspect(map)} is not a map, the second argument to transform must be a map"
  end

  defp validate(type, func) when is_function(func) and is_atom(type) do
    String.starts_with? Atom.to_string(type), "Elixir."
  end

  defp validate(_type, _func) do
    false
  end

  defp wrap(func, type) when is_function(func) do
    case arity(func) do
      2 -> func
      1 -> fn(x, _d) -> func.(x) end
      _ -> raise ArgumentError, "#{inspect(func)} for key #{inspect(type)} in map must have an arity of either 1 or 2"
    end
  end

  defp arity(func) do
    func |> :erlang.fun_info |> Keyword.get(:arity, -1)
  end

  @doc """
  distill extracts the function for a given data type from a potion.

  If the potion does not have a function for a given data type, it
  returns the function from the `Any` key value.
  """
  def distill(type, potion) do
    Map.get(potion, type, Map.get(potion, Any))
  end

end
