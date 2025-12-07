defmodule Sigils.CsvSigil do
  @doc """
  # 練習問題：MoreCoolStuff-2

  `Float.parse`関数は、文字列の先頭の、数値に変換できる部分を浮動小数点数に変換し、\s\s
  変換した値と残りの文字列を含むタプルか、:errorというアトムを返す。\s\s
  CSVシジルを更新して、数値が自動的に変換されるようにしよう。

  ## 例

      iex> use Sigils.CsvSigil
      iex> ~v"""
      ...> 1,2,3.14
      ...> cat,dog
      ...> """
      [[1.0, 2.0, 3.14], ["cat", "dog"]]
      iex> ~v"""
      ...> 1,2,bee
      ...> cat,dog,3.14
      ...> """
      [[1.0, 2.0, "bee"], ["cat", "dog", 3.14]]

  """
  def sigil_v(csv_data, _option) do
    csv_data
    |> String.trim_trailing()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn csv_line -> Enum.map(csv_line, &_float_parse/1) end)
  end

  defp _float_parse(data) do
    data
    |> Float.parse()
    |> (fn
      {result, ""} -> result
      :error -> data
    end).()
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: [sigil_v: 2]
    end
  end
end
