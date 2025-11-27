defmodule Macros.Dumper.My do
  defmacro macro(param) do
    IO.inspect param
  end
end

defmodule Macros.Dumper.Test do
  require Macros.Dumper.My
  alias Macros.Dumper.My

  # これらの値はその値がそのまま表現となる
  My.macro :atom
  My.macro 1
  My.macro 1.0
  My.macro [1, 2, 3]
  My.macro "binaries"
  My.macro {1, 2}
  My.macro do: 1

  # そしてこれらは三つ組のタプルで表現される
  My.macro {1, 2, 3, 4, 5}
  My.macro do: (a = 1; a+a)
  My.macro do
    1 + 2
  else
    3 + 4
  end

  My.macro do
    a = 1 + 2
    a
  else
    a = 3 + 4
    a
  end
end
