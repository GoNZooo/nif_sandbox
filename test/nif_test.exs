defmodule NifTest do
  use ExUnit.Case

  test "basic c nifs" do
    assert CNif.hello() == 'Hello World from C!'
    assert CNif.hello_binary(42) == "cccccccccccccccccccccccccccccccccccccccccc"
    assert_raise ArgumentError, fn -> CNif.hello_binary(4.0) end
    assert CNif.hello_tuple(:tag, 6) == {:tag, [:c, :c, :c, :c, :c, :c]}
  end

  for module <- [CNif.Slots, ZigNif.Slots, OdinNif.Slots] do
    test "#{module} tests" do
      {:ok, resource} = unquote(module).create()
      assert unquote(module).size(resource) == 1
      assert unquote(module).get(resource, 0) == {:ok, :unset}
      assert unquote(module).set(resource, 0, {:value, 42}) == :ok
      assert unquote(module).set(resource, 1, {:value, 42}) == {:error, :index_out_of_bounds}
      assert unquote(module).get(resource, 0) == {:ok, {:value, 42}}
      assert unquote(module).get(resource, 1) == {:error, :index_out_of_bounds}
      assert unquote(module).append(resource, 1337) == :ok
      assert unquote(module).size(resource) == 2
      assert unquote(module).capacity(resource) == 2
      assert unquote(module).append(resource, 69) == :ok
      assert unquote(module).size(resource) == 3
      assert unquote(module).capacity(resource) == 4
      assert unquote(module).append(resource, 59) == :ok
      assert unquote(module).size(resource) == 4
      assert unquote(module).capacity(resource) == 4
      assert unquote(module).get(resource, 0) == {:ok, {:value, 42}}
      assert unquote(module).get(resource, 1) == {:ok, 1337}
      assert unquote(module).get(resource, 2) == {:ok, 69}
      assert unquote(module).reserve(resource, 8) == :ok
      assert unquote(module).size(resource) == 4
      assert unquote(module).capacity(resource) == 8
      assert unquote(module).to_list(resource) == [{:value, 42}, 1337, 69, 59]
    end
  end

  test "zig nifs" do
    assert ZigNif.hello() == 'Hello World from Zig!'
    assert ZigNif.hello_binary(42) == "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    assert_raise ArgumentError, fn -> ZigNif.hello_binary(4.0) end
    assert ZigNif.hello_tuple(:tag, 6) == {:tag, [:zig, :zig, :zig, :zig, :zig, :zig]}
  end

  test "odin nifs" do
    assert OdinNif.hello() == 'Hello World from Odin!'
    assert OdinNif.hello_binary(42) == "oooooooooooooooooooooooooooooooooooooooooo"
    assert_raise ArgumentError, fn -> OdinNif.hello_binary(4.0) end
    assert OdinNif.hello_tuple(:tag, 6) == {:tag, [:odin, :odin, :odin, :odin, :odin, :odin]}
  end
end
