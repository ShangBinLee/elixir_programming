defmodule Sales do
  @moduledoc """
  販売情報の処理関連モジュール
  """

  @doc """
  # 練習問題：StringsAndBinaries-7

  注文リストを記載したファイルを読み込み、\s\s
  指定した税率を適用した注文リストを返す。

  ## パラメータ

    - orders_file_path：注文リスト情報ファイル
      - カラムとして`id`, `ship_to`, `net_amount`を含めるCSV形式のテキスト(.txt)ファイル\s\s
        一行目はヘッダー、二行目から中身になる。
    - tax_rates：注文リストに適用する税率情報
      - 注文先`ship_to`の値をキーとして、その税率を値とするキーワードリスト

  ## 戻り値

    - 注文リストで納税対象の注文に対して\s\s
      税率を適用した後の金額`total_amount`を\s\s
      その注文の新たなフィールドとして追加した注文リスト

  ## 例

      iex> Sales.sales_tax("test/orders_example.txt", [ NC: 0.075, TX: 0.08 ])
      [
        %{id: 123, ship_to: :NC, net_amount: 100.0, total_amount: 107.5},
        %{id: 124, ship_to: :OK, net_amount: 35.5},
        %{id: 125, ship_to: :TX, net_amount: 24.0, total_amount: 25.92},
        %{id: 126, ship_to: :TX, net_amount: 44.8, total_amount: 48.384},
        %{id: 127, ship_to: :NC, net_amount: 25.0, total_amount: 26.875},
        %{id: 128, ship_to: :MA, net_amount: 10.0},
        %{id: 129, ship_to: :CA, net_amount: 102.0},
        %{id: 120, ship_to: :NC, net_amount: 50.0, total_amount: 53.75}
      ]
  """
  @spec sales_tax(Path.t(), keyword(float()))
  :: list(
    %{id: integer(), ship_to: atom(), net_amount: float()}
    | %{id: integer(), ship_to: atom(), net_amount: float(), total_amount: float()}
  )
  def sales_tax(orders_file_path, tax_rates) do
    orders_file_path
    |> File.stream!(:line)
    |> Stream.drop(1) # ヘッダー行をスキップ
    |> Stream.map(&to_order/1) # テキストを注文情報に変換
    |> Orders.apply_tax_rates_to(tax_rates)
  end

  def to_order(line) do
    line
    |> String.trim() # 改行文字を除く
    |> String.split(",")
    |> Enum.map(&_parse_order_info/1)
    |> (fn line -> Enum.zip([:id, :ship_to, :net_amount], line) end).() # ヘッダーと連結
    |> Map.new()
    # to-do：実際にCSVのようにファイルでヘッダー名の記載順番は構わないようにしたい。
  end

  # ship_toカラムのパース
  defp _parse_order_info(":" <> ship_to), do: String.to_atom(ship_to)
  # id(integer)かnet_amount(float)カラムのパース
  defp _parse_order_info(num_str) do
    String.contains?(num_str, ".")
    |> _to_float_integer(num_str)
  end

  defp _to_float_integer(true, num_str), do: String.to_float(num_str)
  defp _to_float_integer(false, num_str), do: String.to_integer(num_str)
end
