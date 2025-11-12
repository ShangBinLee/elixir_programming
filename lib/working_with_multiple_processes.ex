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
end
