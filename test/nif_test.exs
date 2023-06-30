defmodule NifTest do
  use ExUnit.Case

  @modules [CNif, OdinNif, ZigNif]
  @functions [
    hello: {:hello, []},
    hello_binary: {:hello_binary, [42]},
    badarg_hello_binary: {:hello_binary, [4.0]}
  ]

  test "c nifs" do
    assert CNif.hello() == 'Hello World from C!'
    assert CNif.hello_binary(42) == "cccccccccccccccccccccccccccccccccccccccccc"
    assert_raise ArgumentError, fn -> CNif.hello_binary(4.0) end
  end

  test "odin nifs" do
    assert OdinNif.hello() == 'Hello World from Odin!'
    assert OdinNif.hello_binary(42) == "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    assert_raise ArgumentError, fn -> OdinNif.hello_binary(4.0) end
  end

  test "zig nifs" do
    assert ZigNif.hello() == 'Hello World from Zig!'
    assert ZigNif.hello_binary(42) == "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    assert_raise ArgumentError, fn -> ZigNif.hello_binary(4.0) end
  end
end
