defmodule Monitor do
  import :timer, only: [sleep: 1]

  def sad_function do
    sleep 500
    exit(:boom)
  end

  def run do
    res = spawn_monitor(Monitor, :sad_function, [])
    IO.inspect res

    receive do
      msg ->
        IO.puts "メッセージ受信：#{inspect msg}"
      after 1000 ->
        IO.puts "何もなかった！"
    end
  end
end

Monitor.run()
