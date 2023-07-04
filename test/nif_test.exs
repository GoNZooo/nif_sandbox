defmodule NifTest do
  use ExUnit.Case

  test "basic c nifs" do
    assert CNif.hello() == 'Hello World from C!'
    assert CNif.hello_binary(42) == "cccccccccccccccccccccccccccccccccccccccccc"
    assert_raise ArgumentError, fn -> CNif.hello_binary(4.0) end
    assert CNif.hello_tuple(:tag, 6) == {:tag, [:c, :c, :c, :c, :c, :c]}
  end

  test "slots c nifs" do
    {:ok, resource} = CNif.Slots.create()
    assert CNif.Slots.size(resource) == 1
    assert CNif.Slots.get(resource, 0) == {:ok, :unset}
    assert CNif.Slots.set(resource, 0, {:value, 42}) == :ok
    assert CNif.Slots.get(resource, 0) == {:ok, {:value, 42}}
    assert CNif.Slots.get(resource, 1) == {:error, :index_out_of_bounds}
    assert CNif.Slots.append(resource, 1337) == :ok
    assert CNif.Slots.size(resource) == 2
    assert CNif.Slots.capacity(resource) == 2
    assert CNif.Slots.append(resource, 69) == :ok
    assert CNif.Slots.size(resource) == 3
    assert CNif.Slots.capacity(resource) == 4
    assert CNif.Slots.append(resource, 59) == :ok
    assert CNif.Slots.size(resource) == 4
    assert CNif.Slots.capacity(resource) == 4
    assert CNif.Slots.get(resource, 0) == {:ok, {:value, 42}}
    assert CNif.Slots.get(resource, 1) == {:ok, 1337}
    assert CNif.Slots.get(resource, 2) == {:ok, 69}
  end

  test "zig nifs" do
    assert ZigNif.hello() == 'Hello World from Zig!'
    assert ZigNif.hello_binary(42) == "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    assert_raise ArgumentError, fn -> ZigNif.hello_binary(4.0) end
    assert ZigNif.hello_tuple(:tag, 6) == {:tag, [:zig, :zig, :zig, :zig, :zig, :zig]}
  end

  test "slots zig nifs" do
    {:ok, resource} = ZigNif.Slots.create()
    assert ZigNif.Slots.size(resource) == 1024
    assert ZigNif.Slots.get(resource, 0) == {:ok, :unset}
    assert ZigNif.Slots.set(resource, 0, {:value, 42}) == :ok
    assert ZigNif.Slots.get(resource, 0) == {:ok, {:value, 42}}
    assert ZigNif.Slots.get(resource, 1024) == {:error, :index_out_of_bounds}
  end

  test "odin nifs" do
    assert OdinNif.hello() == 'Hello World from Odin!'
    assert OdinNif.hello_binary(42) == "oooooooooooooooooooooooooooooooooooooooooo"
    assert_raise ArgumentError, fn -> OdinNif.hello_binary(4.0) end
    assert OdinNif.hello_tuple(:tag, 6) == {:tag, [:odin, :odin, :odin, :odin, :odin, :odin]}
  end

  test "slots odin nifs" do
    {:ok, resource} = OdinNif.Slots.create()
    assert OdinNif.Slots.size(resource) == 1024
    assert OdinNif.Slots.get(resource, 0) == {:ok, :unset}
    assert OdinNif.Slots.set(resource, 0, {:value, 42}) == :ok
    assert OdinNif.Slots.get(resource, 0) == {:ok, {:value, 42}}
    assert OdinNif.Slots.get(resource, 1024) == {:error, :index_out_of_bounds}
  end
end
