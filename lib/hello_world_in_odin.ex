defmodule HelloWorldInOdin do
  @on_load :init

  def init() do
    :erlang.load_nif("nif/obj/odin/hello_from_odin", 0)
  end

  def hello() do
    :erlang.nif_error("NIF not loaded")
  end
end
