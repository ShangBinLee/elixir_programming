IO.puts inspect self()

defimpl Inspect, for: PID do
  def inspect(pid, _) do
    "#Process: "
    <> IO.iodata_to_binary(:erlang.pid_to_list(pid))
    <> "!!"
  end
end

IO.puts inspect self()
