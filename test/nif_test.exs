defmodule NifTest do
  use ExUnit.Case

  test "c nifs" do
    assert CNif.hello() == 'Hello World from C!'
    assert CNif.hello_binary(42) == "cccccccccccccccccccccccccccccccccccccccccc"
    assert_raise ArgumentError, fn -> CNif.hello_binary(4.0) end
    assert CNif.hello_tuple(:tag, 6) == {:tag, [:c, :c, :c, :c, :c, :c]}
  end

  test "odin nifs" do
    assert OdinNif.hello() == 'Hello World from Odin!'
    assert OdinNif.hello_binary(42) == "oooooooooooooooooooooooooooooooooooooooooo"
    assert_raise ArgumentError, fn -> OdinNif.hello_binary(4.0) end
  end

  test "zig nifs" do
    assert ZigNif.hello() == 'Hello World from Zig!'
    assert ZigNif.hello_binary(42) == "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    assert_raise ArgumentError, fn -> ZigNif.hello_binary(4.0) end
  end
end
