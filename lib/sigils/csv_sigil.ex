defmodule Sigils.CsvSigil do
  @doc """
  # 練習問題：MoreCoolStuff-3

  (難問)ときどき、CSVファイルの最初の行はカラム名であることがある。\s\s
  これをサポートするように更新し、各CSV行がカラム名をキーにしたキーワードリスト\s\s
  になるようにしよ。

  ## 例

      iex> use Sigils.CsvSigil
      iex> ~v\"""
      ...> Item,Qty,Price
      ...> Teddy bear,4,34.95
      ...> Milk,1,2.99
      ...> Battery,6,8.00
      ...> \"""
      [
        [Item: "Teddy bear", Qty: 4, Price: 34.95],
        [Item: "Milk", Qty: 1, Price: 2.99],
        [Item: "Battery", Qty: 6, Price: 8.00],
      ]

  """
  def sigil_v(csv_data, _option) do
    csv_lines = csv_data
      |> String.trim_trailing()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ","))

    column_names =
      csv_lines
      |> Enum.at(0)
      |> Enum.map(&String.to_atom/1)

    csv_lines
    |> Enum.drop(1)
    |> Enum.map(fn csv_line -> Enum.map(csv_line, &_number_parse/1) end)
    |> Enum.map(&Enum.zip(column_names, &1))
  end

  @doc """
  データが数値であればパースされた数値
  そうじゃなければデータをそのまま返却。
  """
  defp _number_parse(data) do
    data
    |> (fn data ->
      if String.contains? data, "." do
        Float.parse(data)
      else
        Integer.parse(data)
      end
    end).()
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
