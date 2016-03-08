defmodule ReFactor do

  import PhStTransform

  def rename_function(old_name, new_name, file) do
    ast = Code.string_to_quoted(File.read!(file))

    new_file = file <> ".new"

    replace = fn(atom) ->
      case atom do
        old_name -> new_name
        atom -> atom
      end
    end

    potion = %{ Atom => replace }
    new_ast = transform(ast, potion )
    new_code = Macro.to_string(new_ast)
    File.write!(new_file, new_code)
  end


end