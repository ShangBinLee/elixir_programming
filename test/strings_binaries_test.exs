defmodule StringsBinariesTest do
  use ExUnit.Case
  doctest StringsBinaries

  defmodule CharListsTest do
    use ExUnit.Case
    doctest StringsBinaries.CharLists
  end

  defmodule StringsTest do
    use ExUnit.Case
    import ExUnit.CaptureIO
    import StringsBinaries.Strings

    test "center string length asc" do
      output_expected = """
        cat
       zebra
      elephant
      """
      assert capture_io(fn -> center(["cat", "zebra", "elephant"]) end) === output_expected
    end

    test "center string length desc" do
      output_expected = """
      reality
      unreal
       unity
      """
      assert capture_io(fn -> center(["reality", "unreal", "unity"]) end) === output_expected
    end
  end
end
