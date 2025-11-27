defmodule Macros.Myif do
  defmacro if(condition, clauses) do
    do_clause = Keyword.get(clauses, :do, nil)
    else_clause = Keyword.get(clauses, :else, nil)

    quote do
      case unquote(condition) do
        val when val in [false, nil]
          -> unquote(else_clause)
        _ -> unquote(do_clause)
      end
    end
  end
end

defmodule Macros.Myif.Test do
  require Macros.Myif
  alias Macros.Myif

  Myif.if 1==2 do
    IO.puts "true"
  else
    IO.puts "false"
  end
end
