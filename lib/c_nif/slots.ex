defmodule CNif.Slots do
  @on_load :init

  def init() do
    :erlang.load_nif("nif/obj/c/slots", 0)
  end

  def create() do
    :erlang.nif_error("NIF not loaded")
  end

  def size(_slots) do
    :erlang.nif_error("NIF not loaded")
  end

  def set(_slots, _index, _value) do
    :erlang.nif_error("NIF not loaded")
  end

  def get(_slots, _index) do
    :erlang.nif_error("NIF not loaded")
  end
end
