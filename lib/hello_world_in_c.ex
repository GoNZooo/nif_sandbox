defmodule HelloWorldInC do
  @on_load :init

  def init() do
    :erlang.load_nif("nif/obj/c/hello_world", 0)
  end

  def hello() do
    :erlang.nif_error("NIF not loaded")
  end

  def hello_binary(_count) do
    :erlang.nif_error("NIF not loaded")
  end
end
