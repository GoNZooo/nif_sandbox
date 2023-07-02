defmodule NifTest do
  use ExUnit.Case

  test "basic c nifs" do
    assert CNif.hello() == 'Hello World from C!'
    assert CNif.hello_binary(42) == "cccccccccccccccccccccccccccccccccccccccccc"
    assert_raise ArgumentError, fn -> CNif.hello_binary(4.0) end
    assert CNif.hello_tuple(:tag, 6) == {:tag, [:c, :c, :c, :c, :c, :c]}
  end

  test "resource creation c nifs" do
    {:ok, resource} = CNif.slots_create()
    assert CNif.slots_size(resource) == 1024
    assert CNif.slots_set(resource, 0, {:value, 42}) == :ok
    assert CNif.slots_get(resource, 0) == {:ok, {:value, 42}}
    assert CNif.slots_get(resource, 1024) == {:error, :index_out_of_bounds}
  end

  test "odin nifs" do
    assert OdinNif.hello() == 'Hello World from Odin!'
    assert OdinNif.hello_binary(42) == "oooooooooooooooooooooooooooooooooooooooooo"
    assert_raise ArgumentError, fn -> OdinNif.hello_binary(4.0) end
    assert OdinNif.hello_tuple(:tag, 6) == {:tag, [:odin, :odin, :odin, :odin, :odin, :odin]}
  end

  test "zig nifs" do
    assert ZigNif.hello() == 'Hello World from Zig!'
    assert ZigNif.hello_binary(42) == "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    assert_raise ArgumentError, fn -> ZigNif.hello_binary(4.0) end
    assert ZigNif.hello_tuple(:tag, 6) == {:tag, [:zig, :zig, :zig, :zig, :zig, :zig]}
  end
end
