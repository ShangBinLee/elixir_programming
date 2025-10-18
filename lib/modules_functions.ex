defmodule ModulesFunctions do
  @moduledoc """
  第6章「モジュールと名前付き関数」に載っている練習問題で興味深い問題の解答
  """

  defmodule Math do
    @moduledoc """
    数学関連モジュール
    """

    @doc """
    # 練習問題：ModulesAndFunctions-4
    `1`から`n`までの総和を求める。

    ## パラメータ

      - n：総和の上限

    ## 例

        iex> ModulesFunctions.Math.sum(1)
        1
        iex> ModulesFunctions.Math.sum(120)
        7260
        iex> ModulesFunctions.Math.sum(147)
        10_878

    """
    @spec sum(pos_integer()) :: pos_integer()
    def sum(1), do: 1
    def sum(n), do: n + sum(n - 1)

    @doc """
    # 練習問題：ModulesAndFunctions-5
    自然数`x`、`y`の最大公約数を求める。（ユークリッドの互除法による数式）

    ## 例

        iex> ModulesFunctions.Math.gcd(100, 0)
        100
        iex> ModulesFunctions.Math.gcd(15, 4)
        1
        iex> ModulesFunctions.Math.gcd(78, 33)
        3
        iex> ModulesFunctions.Math.gcd(100, 60)
        20

    """
    @spec gcd(pos_integer(), pos_integer()) :: pos_integer()
    def gcd(x, 0), do: x
    def gcd(x, y), do: gcd(y, rem(x, y))
  end
end
