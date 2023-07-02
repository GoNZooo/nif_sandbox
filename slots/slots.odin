package slots

import "core:c"
import "core:mem"
import "core:runtime"
// import "core:fmt"
// import "core:runtime"

import "../erldin"

entry: erldin.ErlNifEntry

Slots :: struct {
  data:      []erldin.ERL_NIF_TERM,
  allocator: mem.Allocator,
}

slots_resource_type: ^erldin.ResourceType

slots_destructor :: proc "c" (env: ^erldin.ErlNifEnv, obj: ^rawptr) {
  context = runtime.Context{}

  slots_pointer := transmute(^Slots)obj
  slots := slots_pointer^
  delete(slots.data, slots.allocator)
}

create :: proc "c" (
  env: ^erldin.ErlNifEnv,
  argc: c.int,
  argv: [^]erldin.ERL_NIF_TERM,
) -> erldin.ERL_NIF_TERM {
  context = runtime.Context{}
  context.allocator = runtime.default_allocator()

  slots := Slots {
    allocator = context.allocator,
  }

  data, allocation_error := make([]erldin.ERL_NIF_TERM, 1024, slots.allocator)
  if allocation_error != nil {
    return erldin.enif_make_badarg(env)
  }
  slots.data = data

  resource := erldin.enif_alloc_resource(slots_resource_type, size_of(slots))
  defer erldin.enif_release_resource(resource)
  resource_pointer := transmute(^Slots)resource
  resource_pointer^ = slots
  term := erldin.enif_make_resource(env, resource)

  return erldin.enif_make_tuple(env, 2, erldin.enif_make_atom(env, "ok"), term)
}

size :: proc "c" (
  env: ^erldin.ErlNifEnv,
  argc: c.int,
  argv: [^]erldin.ERL_NIF_TERM,
) -> erldin.ERL_NIF_TERM {
  slots: ^Slots
  if !erldin.enif_get_resource(env, argv[0], slots_resource_type, transmute(^rawptr)&slots) {
    return erldin.enif_make_badarg(env)
  }

  return erldin.enif_make_int(env, i32(len(slots.data)))
}

set :: proc "c" (
  env: ^erldin.ErlNifEnv,
  argc: c.int,
  argv: [^]erldin.ERL_NIF_TERM,
) -> erldin.ERL_NIF_TERM {
  slots: ^Slots
  if !erldin.enif_get_resource(env, argv[0], slots_resource_type, transmute(^rawptr)&slots) {
    return erldin.enif_make_badarg(env)
  }

  index: c.int
  if !erldin.enif_get_int(env, argv[1], &index) {
    return erldin.enif_make_badarg(env)
  }

  value := argv[2]

  if index < 0 || int(index) >= len(slots.data) {
    return erldin.enif_make_tuple(
      env,
      2,
      erldin.enif_make_atom(env, "error"),
      erldin.enif_make_atom(env, "index_out_of_bounds"),
    )
  }

  slots.data[index] = value

  return erldin.enif_make_atom(env, "ok")
}

get :: proc "c" (
  env: ^erldin.ErlNifEnv,
  argc: c.int,
  argv: [^]erldin.ERL_NIF_TERM,
) -> erldin.ERL_NIF_TERM {
  slots: ^Slots
  if !erldin.enif_get_resource(env, argv[0], slots_resource_type, transmute(^rawptr)&slots) {
    return erldin.enif_make_badarg(env)
  }

  index: c.int
  if !erldin.enif_get_int(env, argv[1], &index) {
    return erldin.enif_make_badarg(env)
  }

  if index < 0 || int(index) >= len(slots.data) {
    return erldin.enif_make_tuple(
      env,
      2,
      erldin.enif_make_atom(env, "error"),
      erldin.enif_make_atom(env, "index_out_of_bounds"),
    )
  }

  return erldin.enif_make_tuple(env, 2, erldin.enif_make_atom(env, "ok"), slots.data[index])
}

nif_functions := [?]erldin.ErlNifFunc{
  {name = "create", arity = 0, fptr = erldin.Nif(create), flags = 0},
  {name = "size", arity = 1, fptr = erldin.Nif(size), flags = 0},
  {name = "set", arity = 3, fptr = erldin.Nif(set), flags = 0},
  {name = "get", arity = 2, fptr = erldin.Nif(get), flags = 0},
}

load :: proc "c" (
  env: ^erldin.ErlNifEnv,
  priv_data: [^]rawptr,
  load_info: erldin.ERL_NIF_TERM,
) -> c.int {
  tried: erldin.ResourceFlags
  slots_resource_type = erldin.enif_open_resource_type(
    env,
    nil,
    "OdinSlots",
    erldin.ResourceDestructor(slots_destructor),
    erldin.ResourceFlags.CREATE | erldin.ResourceFlags.TAKEOVER,
    &tried,
  )

  return 0
}

@(export)
nif_init :: proc "c" () -> ^erldin.ErlNifEntry {
  entry.major = 2
  entry.minor = 16
  entry.name = "Elixir.OdinNif.Slots"
  entry.funcs = raw_data(nif_functions[:])
  entry.num_of_funcs = len(nif_functions)
  entry.vm_variant = "beam.vanilla"
  entry.options = 1
  entry.sizeof_ErlNifResourceTypeInit = size_of(erldin.ErlNifResourceTypeInit)
  entry.min_erts = "erts-12.0"
  entry.load = erldin.LoadFunction(load)

  return &entry
}
