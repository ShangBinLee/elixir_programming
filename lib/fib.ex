defmodule Fib do
  @moduledoc """
  フィボナッチ数を求める複数のプロセスで構成されたサーバー
  """
  defmodule FibSolver do
    @moduledoc """
    フィボナッチ数を求める計算サーバー
    """
    def fib(scheduler) do
      send scheduler, {:ready, self()}
      receive do
        {:fib, n, client} ->
          send client, {:answer, n, fib_calc(n), self()}
          fib(scheduler)
        {:shutdown} ->
          exit(:normal)
      end
    end

    defp fib_calc(0), do: 0
    defp fib_calc(1), do: 1
    defp fib_calc(n), do: fib_calc(n - 1) + fib_calc(n - 2)
  end

  defmodule Scheduler do
    @moduledoc """
    タスクスケジューラ。

    n個のワーカープロセスを管理し、渡されたデータを\s\s
    ワーカープロセスに割り振り、ワーカープロセスで\s\s
    割り当てられたデータを引数として関数を実行するようにする。
    """

    @doc """
    n個のプロセスを利用して、渡されたデータを指定された関数で\s\s
    処理する。

    ## パラメータ

      - num_processes：生成するプロセスの数
      - module：実行する関数のモジュール
      - fun：実行する関数
      - to_calculate：処理するデータ

    """
    def run(num_processes, module, fun, to_calculate) do
      1..num_processes
      |> Enum.map(fn _ -> spawn(module, fun, [self()]) end)
      |> schedule_processes(to_calculate, [])
    end

    defp schedule_processes(processes, queue, results) do
      receive do
        # 準備ができて、データが残っている場合
        {:ready, pid} when queue != [] ->
          [next | tail] = queue
          send pid, {:fib, next, self()}
          schedule_processes(processes, tail, results)

        # 準備ができたが、データは処理済みである場合
        {:ready, pid} ->
          send pid, {:shutdown}
          if length(processes) > 1 do # プロセスが起動していると終了させる
            schedule_processes(List.delete(processes, pid), queue, results)
          else
            # 全プロセスが終了したら累積結果を返す
            Enum.sort(results, fn {n1, _}, {n2, _} -> n1 <= n2 end)
          end

        # 計算結果が返った場合
        {:answer, number, result, _pid} ->
          schedule_processes(processes, queue, [{number, result} | results])
      end
    end
  end
end

to_process = List.duplicate(37, 20)
Enum.each 1..10, fn num_processes ->
  {time, result} = :timer.tc(
    Fib.Scheduler, :run,
    [num_processes, Fib.FibSolver, :fib, to_process]
  )
  if num_processes == 1 do
    IO.inspect result
    IO.puts "\n #   計算時間 (s)"
  end
  :io.format "~2B    ~.2f~n", [num_processes, time/1_000_000.0]
end
