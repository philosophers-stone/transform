defmodule Validate do

  import PhStTransform

  def build_validator(data) do
    valid_potion = %{Atom => &from_atom/3,
                     }

   {_, validator } = transmogrify(data, valid_potion)
   validator
  end


  defp from_atom(atom, potion, depth) do
    atom_f = PhStTransform.Potion.distill(Atom, potion)
    new_atom_f = fn
        (a, p, depth) -> true
        (a, p, d) -> atom_f.(a, p, d)
      end
    new_potion = Map.put(potion, Atom, new_atom_f )
    {atom, new_potion}
  end

  # defp from_list([]), do: "[]\n"
  # defp from_list(list), do: "[#{Enum.join(list,",")}]\n"

  # defp from_tuple({}) do
  #   "[]\n"
  # end

  # defp from_tuple(tuple) do
  #   tuple |> Tuple.to_list |> from_list
  # end

  # defp from_keyword([]) do
  #   "{}\n"
  # end

  # defp from_keyword(keyword_list) do
  #   inner = for {key, value} <- keyword_list, into: [], do: "#{from_atom(key)}:#{value}"
  #   "{#{Enum.join(inner,",")}}\n"
  # end

  # defp from_map(map) do
  #   inner = for {key, value} <- map, into: [], do: "\"#{inspect(key)}\":#{value}"
  #   "{#{Enum.join(inner,",")}}\n"
  # end

  # defp from_any(map) when is_map(map) do
  #   %{__struct__: struct_name} = map
  #   "#{from_map(Map.put(Map.from_struct(map),"struct",to_json(struct_name)))}"
  # end

  # defp from_any(any) do
  #   inspect(any)
  # end
end