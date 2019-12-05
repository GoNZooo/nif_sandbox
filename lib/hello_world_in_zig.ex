defmodule HelloWorldInZig do
  @on_load :init

  def init() do
    :erlang.load_nif("nif/obj/zig/libzig_hello_world", 0)
  end

  def hello() do
    :erlang.nif_error("NIF not loaded")
  end
end
