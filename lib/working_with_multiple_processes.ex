defmodule WorkingWithMultipleProcesses do
  @moduledoc """
  第15章「複数のプロセスを使う」に載っている練習問題で興味深い問題の解答
  """

  defmodule FredBetty do
    @moduledoc """
    # 練習問題：WorkingWithMultipleProcesses-2

    二つのプロセスを生成し、それぞれのプロセスにユニークなトークンを渡すプログラム\s\s
    を作ろう。プロセスは受け取ったトークンを送り返すようにする。
      - プロセスから戻ってくる返事の順序は理論的に決定的であるか？ 実際は？
      - もしその答えが「No」であるなら、どうすれば順序を決定的にできるだろうか？
    """

    def send_token_to(name, token) do
      receive do
        send_to when is_pid(send_to) -> # 送信先はrun関数から
          send send_to, token
          send_token_to(name, token) # トークン待ち受ける
        token when is_atom(token) ->
          IO.puts("#{name}がトークン「#{token}」を受け取りました。")
      end
    end

    def run() do
      fred_p = spawn(WorkingWithMultipleProcesses.FredBetty, :send_token_to, ["fred", :fred])
      betty_p = spawn(WorkingWithMultipleProcesses.FredBetty, :send_token_to, ["betty", :betty])

      send fred_p, betty_p
      send betty_p, fred_p
    end
  end

  defmodule Problem3 do
    @moduledoc """
    # 練習問題：WorkingWithMultipleProcesses-3

    spawn_linkを使ってプロセスを生成し、そのプロセスで親プロセスへメッセージを送信した後、\s\s
    すぐに終了するようにしてみよう。その間、親プロセスでは500ミリ秒スリープし、その後で、\s\s
    受信を待機しているメッセージをすべて受信するようにしよう。何を受信するか、調査してほしい。\s\s
    子プロセスが終了するとき、子プロセスからの通知を待っていないことが問題になるだろうか？
    """
    import :timer, only: [sleep: 1]

    def child_process(send_to, sleep_time) do
      send send_to, "子プロセスからのメッセージです。"
      if sleep_time > 0, do: sleep sleep_time
      exit(:boom)
    end


    @doc """
    親プロセス。

    sleep_timeを
    1. 0（子プロセスがすぐ終了）
    1. 500（親プロセスのsleep時間と同じ）
    3. 500より大きい数

    に指定して確認してみよう。

    ## パラメータ

      - sleep_time：子プロセスに指定するsleep時間（ミリ秒）

    ## 例

        iex>WorkingWithMultipleProcesses.Problem3.run(0)
        # メッセージ受信前にプロセス異常終了
        iex>WorkingWithMultipleProcesses.Problem3.run(500)
        # 500ミリ秒sleepし、メッセージ受信前にプロセス異常終了
        iex>WorkingWithMultipleProcesses.Problem3.run(600)
        # 600ミリ秒sleepし、メッセージ受信後、プロセス異常終了
    """
    def run(sleep_time) do
      spawn_link(WorkingWithMultipleProcesses.Problem3, :child_process, [self(), sleep_time])
      sleep 500

      receive do
        msg ->
          "メッセージ受信：#{msg}"
      end
    end
  end

  defmodule Problem4 do
    @moduledoc """
    # 練習問題：WorkingWithMultipleProcesses-4

    同じように、しかい子プロセスが終了の代わりに例外を発生するようにしてみよう。\s\s
    何か出力に違いはあるだろうか。
    """
    import :timer, only: [sleep: 1]

    def child_process(send_to) do
      send send_to, "子プロセスからのメッセージです。"
      raise "子プロセス異常終了！"
    end


    @doc """
    親プロセス。
    """
    def run() do
      spawn_link(WorkingWithMultipleProcesses.Problem4, :child_process, [self()])
      sleep 500

      receive do
        msg ->
          "メッセージ受信：#{msg}"
      end
    end
  end

  defmodule Problem5 do
    @moduledoc """
    # 練習問題：WorkingWithMultipleProcesses-5

    前二つの練習問題を、spawn_linkからspawn_monitorに変えて繰り返してみよう。
    """
    import :timer, only: [sleep: 1]

    @doc """
    親プロセス。練習問題：WorkingWithMultipleProcesses-3のspawn_monitor版
    """
    def run_1() do
      spawn_monitor(WorkingWithMultipleProcesses.Problem3, :child_process, [self(), 0])
      sleep 500

      receive do
        msg ->
          IO.puts "メッセージ受信：#{inspect msg}"
      end

      receive do
        msg ->
          IO.puts "メッセージ受信：#{inspect msg}"
      end
    end

    @doc """
    親プロセス。練習問題：WorkingWithMultipleProcesses-4のspawn_monitor版
    """
    def run_2() do
      spawn_monitor(WorkingWithMultipleProcesses.Problem4, :child_process, [self()])
      sleep 500

      receive do
        msg ->
          IO.puts "メッセージ受信：#{inspect msg}"
      end

      receive do
        msg ->
          IO.puts "メッセージ受信：#{inspect msg}"
      end
    end
  end

  defmodule Problem9 do
    @moduledoc """
    # 練習問題：WorkingWithMultipleProcesses-9

    このスケジューラのコードを更新し、ディレクトリの中のファイルに"cat"という単語が\s\s
    何個含まれているか数えるプログラムを書いてみよう。ファイルごとにサーバプロセスを作ろう。\s\s
    File.ls!がディレクトリ中のファイルを返し、File.read!がファイルの中身をバイナリで読み込む。\s\s
    より汎用化スケジューラとして書くことができるだろうか？ぼどぼどの数のファイル（たぶん、100くらい）\s\s
    のあるディレクトリで、このコードを走らせてみよう。並行性の効果を体験できるだろう。
    """

    defmodule Reader do
    @moduledoc """
    対象ファイルで対象単語を調べて数えるサーバープロセス

    ## メッセージ送信

      s-1. {:ready, self()}
        1. 次のファイルを調査する準備ができたことをスケジューラにお知らせする。
        2. 次のメッセージを待機する。
      s-2. {:answer, result}
        1. 対象ファイルにての調査結果をスケジューラに送り返す。

    ## メッセージ受信

      r-1. {:run, file_path}
        1. 対象ファイルにて、対象単語の数を数える。
        2. s-2を行う。
        3. s-1を行う。
      r-2. {:shutdown}
        1. プロセスを終了する。

    """

      @doc """
      プロセスが実行する関数

      ## パラメータ

        - scheduler：スケジューラのpid
        - word：対象単語

      """
      def run(scheduler, word) do
        send scheduler, {:ready, self()}

        receive do
          {:run, file_path} ->
            result = file_path |> _read() |> _grep_count(word)
            send scheduler, {:answer, result}
            run(scheduler, word)
          {:shutdown} ->
            exit(:normal)
        end
      end

      defp _read(file_path) do
        File.stream!(file_path, :line)
      end

      defp _grep_count(file_stream, word) do
        file_stream
        |> Stream.map(&String.count(&1, word))
        |> Enum.sum()
      end
    end

    defmodule Scheduler do
      @moduledoc """
      n個のワーカープロセスにて渡されたデータに対して対象関数を実行し\s\s
      その結果をまとめて返すスケジューラ。

      1. ワーカープロセスにデータを振り分け
      2. 手が空いているプロセスに関数を実行させ
      3. その結果をまとめ
      4. 処理完了時、全ワーカープロセスを終了させ
      5. 結果を返す。

      """

      @doc """
      プロセスが実行する関数

      ## パラメータ

        - num_processes：起動するワーカープロセスの数
        - module：ワーカープロセスで実行する関数のモジュール
        - fun：ワーカープロセスで実行する関数
        - args_to_process：ワーカープロセスの`run`関数に渡す引数のリスト
        - data_to_process：処理するデータ

      """
      def run(num_processes, module, fun, args_to_process, data_to_process) do
        1..num_processes
        |> Enum.map(fn _ -> spawn_monitor(module, fun, [self() | args_to_process]) end)
        |> Enum.map(fn {pid, _} -> pid end) # 使用するプロセスのPIDリストに変換
        |> _schedule_processes(data_to_process, [])
      end

      defp _schedule_processes(working_processes, queue, results) do
        if working_processes === [] do
          # 全ワーカープロセスが終了したら結果をまとめて返す。
          results |> Enum.sum()
        else
          receive do
            {:ready, pid} when queue === [] ->
              # 処理完了時、ワーカープロセスを終了させる。
              # 全ワーカープロセスが終了するまで回帰する。
              send pid, {:shutdown}
              _schedule_processes(working_processes, queue, results)
            {:ready, pid} ->
              # 残りのデータがあれば、プロセスに振り分けて関数を実行させる。
              [next | tail] = queue
              send pid, {:run, next}
              _schedule_processes(working_processes, tail, results)
            {:answer, result} ->
              # 結果が返ったら、結果リストの先頭に追加する。
              _schedule_processes(working_processes, queue, [result | results])
            {:DOWN, _, :process, pid, :normal} ->
              # プロセスが正常終了したら起動中のプロセスリストから除く。
              List.delete(working_processes, pid)
              |> _schedule_processes(queue, results)
          end
        end
      end
    end

    @doc """
    1個からn個まで各ワーカープロセスの数にて\s\s
    対象ディレクトリの全ファイルで\s\s
    `"cat"`のcountを求めて\s\s
    その合計を1回出力し、\s\s
    プロセスの数ごとに計算時間を出力する。

    ## パラメータ

      - num_processes_range：ワーカープロセスの数の範囲
      - directory_path：対象ディレクトリ

    """
    def run(num_processes_range, directory_path) do
      file_paths = directory_path
        |> File.ls!()
        |> Enum.reject(&File.dir?/1)
        |> Enum.map(&"#{directory_path}/#{&1}")
      num_processes_max = Enum.at(num_processes_range, -1)

      num_processes_range
      |> Enum.map(fn num_process ->
         # ワーカープロセスの数ごとに計算時間の計測を行う
        {
          num_process,
          :timer.tc(Scheduler, :run, [num_process, Reader, :run, ["cat"], file_paths])
        }
      end)
      |> (fn [
          _head = {num_processes_min, _tc_result = {time, result}}
          | tail
        ] ->
        # 概要、最初の結果を出力する
        num_width = _num_width(num_processes_max)

        IO.puts "計算結果：#{inspect result}"
        :io.format("~-#{num_width}s ~ts~n", ["num", "計算時間"])
        _puts_result(num_width, num_processes_min, time)

        tail
      end).()
      |> Enum.each(fn { num_process, _tc_result = {time, _} } ->
        # それ以降の出力をする
        _num_width(num_processes_max)
        |> _puts_result(num_process, time)
      end)
    end

    defp _num_width(num_processes_max) do
      num_processes_max
      |> to_string()
      |> String.length()
      |> max(String.length("num"))
    end
    defp _puts_result(num_width, num_process, time) do
      :io.format("~-#{num_width}B ~.2f~n", [num_process, time/1_000_000.0])
    end
  end
end
