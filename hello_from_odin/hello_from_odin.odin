package hello_from_odin

import "core:c"
// import "core:fmt"
import "core:runtime"

import "../erldin"

entry: erldin.ErlNifEntry

hello :: proc "c" (
  env: ^erldin.ErlNifEnv,
  argc: c.int,
  argv: [^]erldin.ERL_NIF_TERM,
) -> erldin.ERL_NIF_TERM {
  return erldin.enif_make_string(
    env,
    "Hello World from Odin!",
    u32(erldin.encoding.ERL_NIF_LATIN1),
  )
}

hello_binary :: proc "c" (
  env: ^erldin.ErlNifEnv,
  argc: c.int,
  argv: [^]erldin.ERL_NIF_TERM,
) -> erldin.ERL_NIF_TERM {
  context = runtime.default_context()
  int_value := c.int(0)
  if !erldin.enif_get_int(env, argv[0], &int_value) {
    return erldin.enif_make_badarg(env)
  }

  bytes := make([]u8, int_value)
  for &c in bytes {
    c = 'a'
  }
  binary := erldin.ErlNifBinary {
    size = c.size_t(int_value),
    data = raw_data(bytes),
  }
  binary_value := erldin.enif_make_binary(env, &binary)

  return binary_value
}

nif_functions := [?]erldin.ErlNifFunc{
  {name = "hello", arity = 0, fptr = erldin.Nif(hello), flags = 0},
  {name = "hello_binary", arity = 1, fptr = erldin.Nif(hello_binary), flags = 0},
}

@(export)
nif_init :: proc "c" () -> ^erldin.ErlNifEntry {
  entry.major = 2
  entry.minor = 16
  entry.name = "Elixir.OdinNif"
  entry.funcs = raw_data(nif_functions[:])
  entry.num_of_funcs = len(nif_functions)
  entry.vm_variant = "beam.vanilla"
  entry.options = 1
  entry.sizeof_ErlNifResourceTypeInit = size_of(erldin.ErlNifResourceTypeInit)
  entry.min_erts = "erts-12.0"

  return &entry
}
