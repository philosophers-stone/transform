defmodule Validate do

  import PhStTransform

  def build_validator(data) do
    valid_potion = %{ Atom => &from_atom/3,
                      Integer => &from_integer/3,
                      Float   =>  &from_float/3,
                      BitString => &from_bitstring/3,
                     }

    {_, validator } = transmogrify(data, valid_potion)
    fn new_data ->
      PhStTransform.transform(new_data, PhStTransform.Potion.brewify(validator))
    end
  end

  #[Atom, Integer, Float, BitString, Regexp, PID, Function, Reference, Port, Tuple, List, Map]
  # I should really learn how to at least make all the basic types via macros.

  defp from_atom(_atom, potion, depth) do
    atom_f = PhStTransform.Potion.distill(Atom, potion)
    new_atom_f = fn
        (_a, p, ^depth) -> {true, p}
        (a, p, d) -> atom_f.(a, p, d)
      end
    new_potion = Map.put(potion, Atom, new_atom_f )
    {false, new_potion}
  end

  defp from_integer(_integer, potion, depth) do
    integer_f = PhStTransform.Potion.distill(Integer, potion)
    new_integer_f = fn
        (_i, p, ^depth) -> {true, p}
        (i, p, d) -> integer_f.(i, p, d)
      end
    new_potion = Map.put(potion, Integer, new_integer_f )
    {false, new_potion}
  end

  defp from_float(_float, potion, depth) do
    float_f = PhStTransform.Potion.distill(Float, potion)
    new_float_f = fn
        (_f, p, ^depth) -> {true, p}
        (f, p, d) -> float_f.(f, p, d)
      end
    new_potion = Map.put(potion, Float, new_float_f )
    {false, new_potion}
  end

  defp from_bitstring(_bitstring, potion, depth) do
    bitstring_f = PhStTransform.Potion.distill(BitString, potion)
    new_bitstring_f = fn
        (_b, p, ^depth) -> {true, p}
        (b, p, d) -> bitstring_f.(b, p, d)
      end
    new_potion = Map.put(potion, BitString, new_bitstring_f )
    {false, new_potion}
  end

end