defmodule Macros.Eg.My do
  defmacro macro(code) do
    IO.inspect code
    quote do: IO.puts "別のコード"
  end
end

defmodule Macros.Eg.Test do
  require Macros.Eg.My
  alias Macros.Eg.My

  My.macro IO.puts "hello"
end
