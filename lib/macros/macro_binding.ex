defmodule Macros.MacroBinding do
  defmacro mydef(name) do
    quote bind_quoted: [name: name] do
      def unquote(name)(), do: unquote(name)
    end
  end
end

defmodule Macros.MacroBinding.Test do
  require Macros.MacroBinding
  alias Macros.MacroBinding

  [:fred, :bert] |> Enum.each(&MacroBinding.mydef(&1)) # &1に値が束縛されてからマクロ実行
end

IO.puts Macros.MacroBinding.Test.fred
