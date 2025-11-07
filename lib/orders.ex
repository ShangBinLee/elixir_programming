defmodule Orders do
  @moduledoc """
  注文関連処理を行うモジュール
  """

  @doc """
  # 練習問題：ListsAndRecursion-8

  与えられた税率リストに従って、納税対象の注文に税金をかけた注文リストを返す。

  ## パラメータ

    - orders：注文リスト
      - **データ形式**：`[ order1, order2, ... ]`
      - order：注文、注文ID、送付先、純額が含まれている
        - **データ形式**：`[ id: ..., ship_to: 送付先, net_amount: 純額 ]`
    - tax_rates：税率リスト、送付先に対しての税率が記載されたもの
      - **データ形式**：`[ 送付先1: 税率, 送付先2: 税率, ... ]`

  ## 例

      iex> Orders.apply_tax_rates_to(
      ...> [
      ...>  [ id: 123, ship_to: :NC, net_amount: 100.00 ],
      ...>  [ id: 124, ship_to: :OK, net_amount: 35.50 ],
      ...>  [ id: 125, ship_to: :TX, net_amount: 24.00 ],
      ...>  [ id: 126, ship_to: :TX, net_amount: 44.80 ],
      ...>  [ id: 127, ship_to: :NC, net_amount: 25.00 ],
      ...>  [ id: 128, ship_to: :MA, net_amount: 10.00 ],
      ...>  [ id: 129, ship_to: :CA, net_amount: 102.00 ],
      ...>  [ id: 130, ship_to: :NC, net_amount: 50.00 ],
      ...> ],
      ...> [ NC: 0.075, TX: 0.08 ])
      [
        [ id: 123, ship_to: :NC, net_amount: 100.00, total_amount: 107.5 ],
        [ id: 124, ship_to: :OK, net_amount: 35.50 ],
        [ id: 125, ship_to: :TX, net_amount: 24.00, total_amount: 25.92 ],
        [ id: 126, ship_to: :TX, net_amount: 44.80, total_amount: 48.384 ],
        [ id: 127, ship_to: :NC, net_amount: 25.00, total_amount: 26.875 ],
        [ id: 128, ship_to: :MA, net_amount: 10.00 ],
        [ id: 129, ship_to: :CA, net_amount: 102.00 ],
        [ id: 130, ship_to: :NC, net_amount: 50.00, total_amount: 53.75 ],
      ]
      iex> Orders.apply_tax_rates_to(
      ...> [
      ...>  [ id: 123, ship_to: :NC, net_amount: 100.00 ],
      ...>  [ id: 129, ship_to: :CA, net_amount: 102.00 ],
      ...> ],
      ...> [])
      [
        [ id: 123, ship_to: :NC, net_amount: 100.00 ],
        [ id: 129, ship_to: :CA, net_amount: 102.00 ],
      ]

  """
  def apply_tax_rates_to(orders, tax_rates) do
    for order = [id: _, ship_to: ship_to, net_amount: net_amount] <- orders do
      Keyword.get(tax_rates, ship_to)
      |> (&apply_tax_rate_to(&1, order, net_amount)).()
    end
  end

  # 税率情報が見つからない場合、注文を変更せず返す。
  defp apply_tax_rate_to(nil, order, _), do: order
  defp apply_tax_rate_to(tax_rate, order, net_amount) do
    order ++ [total_amount: net_amount * (1 + tax_rate)]
  end
end
