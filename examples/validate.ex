defmodule Validate do

  import PhStTransform

  def build_validator(data) do
    valid_potion = %{ Atom => &from_atom/3,
                      Integer => &from_integer/3,
                      Float   =>  &from_float/3,
                      BitString => &from_bitstring/3,
                      Regexp => &from_regex/3,
                      PID => &from_pid/3,
                      Function => &from_function/3,
                      Reference => &from_reference/3,
                      Port => &from_port/3
                     }

   {_, validator } = transmogrify(data, valid_potion)
   PhStTransform.Potion.brewify(validator)
  end

  #[Atom, Integer, Float, BitString, Regexp, PID, Function, Reference, Port, Tuple, List, Map]
  # I should really learn how to at least make all the basic types via macros.

  defp from_atom(atom, potion, depth) do
    atom_f = PhStTransform.Potion.distill(Atom, potion)
    new_atom_f = fn
        (a, p, ^depth) -> {true, p}
        (a, p, d) -> atom_f.(a, p, d)
      end
    new_potion = Map.put(potion, Atom, new_atom_f )
    {false, new_potion}
  end

  defp from_integer(integer, potion, depth) do
    integer_f = PhStTransform.Potion.distill(Integer, potion)
    new_integer_f = fn
        (a, p, ^depth) -> {true, p}
        (a, p, d) -> integer_f.(a, p, d)
      end
    new_potion = Map.put(potion, Integer, new_integer_f )
    {false, new_potion}
  end

  defp from_float(float, potion, depth) do
    float_f = PhStTransform.Potion.distill(Float, potion)
    new_float_f = fn
        (a, p, ^depth) -> {true, p}
        (a, p, d) -> float_f.(a, p, d)
      end
    new_potion = Map.put(potion, Float, new_float_f )
    {false, new_potion}
  end

  defp from_bitstring(bitstring, potion, depth) do
    bitstring_f = PhStTransform.Potion.distill(Bitstring, potion)
    new_bitstring_f = fn
        (a, p, ^depth) -> {true, p}
        (a, p, d) -> bitstring_f.(a, p, d)
      end
    new_potion = Map.put(potion, Bitstring, new_bitstring_f )
    {false, new_potion}
  end

end