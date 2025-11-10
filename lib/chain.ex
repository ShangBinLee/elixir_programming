defmodule Chain do
  def counter(next_pid) do
    receive do
      n ->
        send next_pid, n + 1
    end
  end

  def create_processes(n) do
    last = Enum.reduce(1..n, self(), fn (_, send_to) ->
      spawn(Chain, :counter, [send_to])
    end)

    send last, 0

    receive do
      final_answer when is_integer(final_answer) -> # コンパイラプロセスからのメッセージ残骸の入り込みを防ぐため
        "合計：#{inspect(final_answer)}"
    end
  end

  @doc """
  n個のプロセスが順に前のプロセスからの数字に1を足して次のプロセスに渡す。

  ## 例

      $ elixir -r lib/chain.ex -e "Chain.run(10)"
      $ elixir -r lib/chain.ex -e "Chain.run(100)"
      $ elixir -r lib/chain.ex -e "Chain.run(1_000)"
      $ elixir -r lib/chain.ex -e "Chain.run(10_000)"
      $ elixir -r lib/chain.ex -e "Chain.run(100_000)"
      $ elixir -r lib/chain.ex -e "Chain.run(1_000_000)"
      $ elixir -r lib/chain.ex -e "Chain.run(1_100_000)"
      $ elixir --erl "+P 2000000" -r lib/chain.ex -e "Chain.run(1_100_000)"
      $ elixir --erl "+P 2000000" -r lib/chain.ex -e "Chain.run(2_000_000)"
  """
  def run(n) do
    :timer.tc(Chain, :create_processes, [n]) # 実行時間はマイクロ秒単位
    |> IO.inspect()
  end
end
