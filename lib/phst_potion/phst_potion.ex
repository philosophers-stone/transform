defmodule PhStTransform.Potion do
  @moduledoc """
  This module provides some helper methods for creating maps that
  work with the `PhStTransform` Protocol.

  The methods in this module that are public are not intended to
  be used outside of writing a implementation of the `PhStTransform` Protocol.
  """

  @doc """
  brew validates and prepares a map to be used with the `PhStTransform` Protocol.

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

  @doc """
  brewify converts a potion from transmogrify form into one compatible with transform.

  The idea is to use transmogrify to build a potion that can be used in transforms.
  """
  def brewify(map) do
    for {type, func} <- map, validate(type, func), into: %{} , do: {type, concoct_to_brew(func, map)}
  end

  # We assume func has arity3
  defp concoct_to_brew(func, map) do
    fn(x, d) ->
      {value, _potion} = func.(x, map, d)
      value
    end
  end

  @doc """
  concoct is the version of brew used in transmogrify, it expects functions of either
  arity 2 or 3 and use a similar wrap function. It also checks for whether any functions
  need wrapping at every level.
  """
  def concoct(map, []) when is_map(map) do
    potion = for {type, func} <- map, validate(type, func) , into: %{} , do: {type, swrap(func, type)}
    Map.put_new(potion, Any, fn(x, p, _d) -> {x, p} end)
  end

  def concoct(map, depth) when is_map(map) and is_list(depth) do
    for {type, func} <- map, validate(type, func) , into: %{} , do: {type, swrap(func, type)}
  end

  def concoct(map, _depth) do
    raise ArgumentError, "#{inspect(map)} is not a map, the second argument to transmogrify must be a map"
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

  defp swrap(func, type) when is_function(func) do
    case arity(func) do
      3 -> func
      2 -> fn(x, p, _d) -> func.(x, p) end
      _ -> raise ArgumentError, "#{inspect(func)} for key #{inspect(type)} in map must have an arity of either 3 or 2"
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
