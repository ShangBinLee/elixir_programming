defmodule Sigils.CsvSigil do
  @doc """
  # 練習問題：MoreCoolStuff-1

  `~v`というシジルを書いてみよう。これは、複数行のカンマで区切られたデータをパースし、\s\s
  データのCSV行のリストを返す。各CSV行は、カンマで区切られた値のリストだ。\s\s
  クオートについては心配しないでもいい。単純に、各フィールドがカンマで区切られていると想定すればいい。\s\s

  ## 例

      iex> use Sigils.CsvSigil
      iex> ~v"""
      ...> 1,2,3
      ...> cat,dog
      ...> """
      [["1", "2", "3"], ["cat", "dog"]]

  """
  def sigil_v(csv_data, _option) do
    csv_data
    |> String.trim_trailing()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: [sigil_v: 2]
    end
  end
end
