defmodule ModulesFunctionsTest do
  use ExUnit.Case
  doctest ModulesFunctions

  defmodule MathTest do
    use ExUnit.Case
    doctest ModulesFunctions.Math
  end
end
