defprotocol Collection do
  @fallback_to_any true
  def is_collection?(value)
end

defimpl Collection, for: [List, Tuple, BitString, Map] do
  def is_collection?(_), do: true
end

defimpl Collection, for: Any do
  def is_collection?(_), do: false
end

for value <- [1, 1.0, [1.2], {1,2}, %{}, "cat"] do
  IO.puts "#{inspect value}: #{Collection.is_collection?(value)}"
end
