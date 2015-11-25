defmodule ToJson do

  import PhStTransform

  def to_json(data) do
    json_potion = %{Atom => &from_atom/1,
                    List => &from_list/1,
                    Tuple => &from_tuple/1 ,
                    Keyword => &from_keyword/1,
                    Map => &from_map/1,
                    Any => &from_any/1 }

    "#{transform(data, json_potion)}"
  end

  defp from_atom(atom), do: "\"#{inspect(atom)}\""

  defp from_list([]), do: "[]\n"
  defp from_list(list), do: "[#{Enum.join(list,",")}]\n"

  defp from_tuple({}) do
    "[]\n"
  end

  defp from_tuple(tuple) do
    tuple |> Tuple.to_list |> from_list
  end

  defp from_keyword([]) do
    "{}\n"
  end

  defp from_keyword(keyword_list) do
    inner = for {key, value} <- keyword_list, into: [], do: "#{from_atom(key)}:#{value}"
    "{#{Enum.join(inner,",")}}\n"
  end

  defp from_map(map) do
    inner = for {key, value} <- map, into: [], do: "\"#{inspect(key)}\":#{value}"
    "{#{Enum.join(inner,",")}}\n"
  end

  defp from_any(map) when is_map(map) do
    %{__struct__: struct_name} = map
    "#{from_atom(struct_name)}:#{from_map(Map.from_struct(map))}"
  end

  defp from_any(any) do
    inspect(any)
  end
end