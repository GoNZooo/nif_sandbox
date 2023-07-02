defmodule CNif do
  @on_load :init

  def init() do
    :erlang.load_nif("nif/obj/c/nifs", 0)
  end

  def hello() do
    :erlang.nif_error("NIF not loaded")
  end

  def hello_binary(_count) do
    :erlang.nif_error("NIF not loaded")
  end

  def hello_tuple(_tag, _count) do
    :erlang.nif_error("NIF not loaded")
  end

  def slots_create() do
    :erlang.nif_error("NIF not loaded")
  end

  def slots_size(_slots) do
    :erlang.nif_error("NIF not loaded")
  end

  def slots_set(_slots, _index, _value) do
    :erlang.nif_error("NIF not loaded")
  end

  def slots_get(_slots, _index) do
    :erlang.nif_error("NIF not loaded")
  end
end
