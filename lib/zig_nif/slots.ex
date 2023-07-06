defmodule ZigNif.Slots do
  @on_load :init

  def init() do
    :erlang.load_nif('nif/obj/zig/slots', 0)
  end

  def create() do
    :erlang.nif_error("NIF not loaded")
  end

  def size(_slots) do
    :erlang.nif_error("NIF not loaded")
  end

  def capacity(_slots) do
    :erlang.nif_error("NIF not loaded")
  end

  def reserve(_slots, _capacity) do
    :erlang.nif_error("NIF not loaded")
  end

  def set(_slots, _index, _value) do
    :erlang.nif_error("NIF not loaded")
  end

  def get(_slots, _index) do
    :erlang.nif_error("NIF not loaded")
  end

  def append(_slots, _value) do
    :erlang.nif_error("NIF not loaded")
  end

  def to_list(_slots) do
    :erlang.nif_error("NIF not loaded")
  end
end
