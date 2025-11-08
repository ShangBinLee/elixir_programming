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
      iex> Sales.sales_tax("test/orders_example_headers_order.txt", [ NC: 0.075, TX: 0.08 ])
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
      iex> Sales.sales_tax("test/orders_example_additional.txt", [ NC: 0.075, TX: 0.08 ])
      [
        %{id: 123, ship_to: :NC, net_amount: 100.0, total_amount: 107.5, delivery_date: "2025-10-28T18:25:34.609Z"},
        %{id: 124, ship_to: :OK, net_amount: 35.5, delivery_date: "2024-12-25T12:25:34.609Z"},
        %{id: 125, ship_to: :TX, net_amount: 24.0, total_amount: 25.92, delivery_date: "2025-03-17T02:21:34.609Z"},
        %{id: 126, ship_to: :TX, net_amount: 44.8, total_amount: 48.384, delivery_date: "2026-01-01T00:00:00.609Z"}
      ]
  """
  @spec sales_tax(Path.t(), keyword(float()))
  :: list(
    %{id: integer(), ship_to: atom(), net_amount: float()}
    | %{id: integer(), ship_to: atom(), net_amount: float(), total_amount: float()}
  )
  def sales_tax(orders_file_path, tax_rates) do
    stream = orders_file_path
    |> File.stream!(:line)

    head = stream
    |> Enum.at(0) # ヘッダー名の列挙文字列を抽出
    |> parse_head() # アトムのリストに変換（バリデーション処理付）

    stream
    |> Stream.drop(1) # 注文（文字列）リスト抽出
    |> Stream.map(&parse_order(&1, head)) # 注文リストに変換
    |> Orders.apply_tax_rates_to(tax_rates) # 税率適用
  end

  def parse_head(line) do
    line
    |> String.trim() # 改行文字を除く
    |> String.split(",")
    |> Enum.map(&_parse_header/1) # アトムのリストに変換
    |> _valid_head() # 必須カラムが含まれているかを確認
    |> _get_head_if_ok() # 異常であればパターンマッチングでエラー
  end

  defp _parse_header(column_name), do: String.to_atom(column_name)

  defp _valid_head(head) do
    headers_not_included = [:id, :ship_to, :net_amount] -- head

    case headers_not_included do
      [] -> {:ok, head}
      _ -> {:validation_error, headers_not_included}
    end
  end

  defp _get_head_if_ok({:ok, head}), do: head

  def parse_order(order_str, head) do
    order_str
    |> String.trim() # 改行文字を除く
    |> String.split(",")
    |> (fn order_info_list -> Enum.zip(head, order_info_list) end).() # ヘッダー名と対象フィールドの値を連結
    |> Enum.map(&_parse_order_info/1) # フィールドごとにパース
    |> Map.new()
  end

  defp _parse_order_info({:ship_to, ":" <> ship_to}), do: {:ship_to, String.to_atom(ship_to)}
  defp _parse_order_info({:id, num_str}), do: {:id, String.to_integer(num_str)}
  defp _parse_order_info({:net_amount, num_str}), do: {:net_amount, String.to_float(num_str)}
  defp _parse_order_info(order_info), do: order_info
end
