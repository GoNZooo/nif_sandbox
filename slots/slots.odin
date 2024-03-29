package slots

import "core:c"
import "core:mem"
import "core:runtime"

import "../erldin"

entry: erldin.NifEntry

Slots :: struct {
  data:      [dynamic]erldin.Term,
  allocator: mem.Allocator,
}

slots_resource_type: ^erldin.ResourceType

slots_destructor :: proc "c" (env: ^erldin.Env, obj: ^rawptr) {
  context = runtime.Context{}

  slots_pointer := cast(^Slots)obj
  slots := slots_pointer^
  delete(slots.data)
}

create :: proc "c" (env: ^erldin.Env, argc: c.int, argv: [^]erldin.Term) -> erldin.Term {
  context = runtime.Context{}
  context.allocator = runtime.default_allocator()

  slots := Slots {
    allocator = context.allocator,
  }

  data, allocation_error := make([dynamic]erldin.Term, 1, 1, slots.allocator)
  if allocation_error != nil {
    return erldin.make_badarg(env)
  }

  for &s in data {
    s = erldin.make_atom(env, "unset")
  }
  slots.data = data

  resource := erldin.alloc_resource(slots_resource_type, size_of(slots))
  defer erldin.release_resource(resource)
  resource_pointer := cast(^Slots)resource
  resource_pointer^ = slots
  term := erldin.make_resource(env, resource)

  return erldin.make_tuple(env, 2, erldin.make_atom(env, "ok"), term)
}

size :: proc "c" (env: ^erldin.Env, argc: c.int, argv: [^]erldin.Term) -> erldin.Term {
  slots: ^Slots
  if !erldin.get_resource(env, argv[0], slots_resource_type, cast(^rawptr)&slots) {
    return erldin.make_badarg(env)
  }

  return erldin.make_int(env, i32(len(slots.data)))
}

capacity :: proc "c" (env: ^erldin.Env, argc: c.int, argv: [^]erldin.Term) -> erldin.Term {
  slots: ^Slots
  if !erldin.get_resource(env, argv[0], slots_resource_type, cast(^rawptr)&slots) {
    return erldin.make_badarg(env)
  }

  return erldin.make_int(env, i32(cap(slots.data)))
}

reserve_space :: proc "c" (env: ^erldin.Env, argc: c.int, argv: [^]erldin.Term) -> erldin.Term {
  slots: ^Slots
  if !erldin.get_resource(env, argv[0], slots_resource_type, cast(^rawptr)&slots) {
    return erldin.make_badarg(env)
  }

  context = runtime.Context{}
  context.allocator = slots.allocator

  capacity: c.int
  if !erldin.get_int(env, argv[1], &capacity) {
    return erldin.make_badarg(env)
  }

  if (int(capacity) <= cap(slots.data)) {
    return erldin.make_atom(env, "ok")
  }

  allocation_error := reserve(&slots.data, int(capacity))
  if allocation_error != nil {
    return alloc_error(env)
  }

  return erldin.make_atom(env, "ok")
}

set :: proc "c" (env: ^erldin.Env, argc: c.int, argv: [^]erldin.Term) -> erldin.Term {
  slots: ^Slots
  if !erldin.get_resource(env, argv[0], slots_resource_type, cast(^rawptr)&slots) {
    return erldin.make_badarg(env)
  }

  index: c.int
  if !erldin.get_int(env, argv[1], &index) {
    return erldin.make_badarg(env)
  }

  value := argv[2]

  if index < 0 || int(index) >= len(slots.data) {
    return erldin.make_tuple(
      env,
      2,
      erldin.make_atom(env, "error"),
      erldin.make_atom(env, "index_out_of_bounds"),
    )
  }

  slots.data[index] = value

  return erldin.make_atom(env, "ok")
}

get :: proc "c" (env: ^erldin.Env, argc: c.int, argv: [^]erldin.Term) -> erldin.Term {
  slots: ^Slots
  if !erldin.get_resource(env, argv[0], slots_resource_type, cast(^rawptr)&slots) {
    return erldin.make_badarg(env)
  }

  index: c.int
  if !erldin.get_int(env, argv[1], &index) {
    return erldin.make_badarg(env)
  }

  if index < 0 || int(index) >= len(slots.data) {
    return erldin.make_tuple(
      env,
      2,
      erldin.make_atom(env, "error"),
      erldin.make_atom(env, "index_out_of_bounds"),
    )
  }

  return erldin.make_tuple(env, 2, erldin.make_atom(env, "ok"), slots.data[index])
}

append_slot :: proc "c" (env: ^erldin.Env, argc: c.int, argv: [^]erldin.Term) -> erldin.Term {
  slots: ^Slots
  if !erldin.get_resource(env, argv[0], slots_resource_type, cast(^rawptr)&slots) {
    return erldin.make_badarg(env)
  }

  context = runtime.Context{}
  context.allocator = slots.allocator

  value := argv[1]

  if (len(slots.data) == cap(slots.data)) {
    allocator_error := reserve(&slots.data, len(slots.data) * 2)
    if allocator_error != nil {
      return alloc_error(env)
    }
  }
  append(&slots.data, value)

  return erldin.make_atom(env, "ok")
}

to_list :: proc "c" (env: ^erldin.Env, argc: c.int, argv: [^]erldin.Term) -> erldin.Term {
  slots: ^Slots
  if !erldin.get_resource(env, argv[0], slots_resource_type, cast(^rawptr)&slots) {
    return erldin.make_badarg(env)
  }

  context = runtime.Context{}
  context.allocator = slots.allocator

  return erldin.make_list_from_array(env, raw_data(slots.data), u32(len(slots.data)))
}

alloc_error :: proc(env: ^erldin.Env) -> erldin.Term {
  return erldin.make_tuple(
    env,
    2,
    erldin.make_atom(env, "error"),
    erldin.make_atom(env, "alloc_error"),
  )
}

nif_functions := [?]erldin.NifFunc{
  {name = "create", arity = 0, fptr = erldin.Nif(create), flags = 0},
  {name = "size", arity = 1, fptr = erldin.Nif(size), flags = 0},
  {name = "capacity", arity = 1, fptr = erldin.Nif(capacity), flags = 0},
  {name = "reserve", arity = 2, fptr = erldin.Nif(reserve_space), flags = 0},
  {name = "set", arity = 3, fptr = erldin.Nif(set), flags = 0},
  {name = "get", arity = 2, fptr = erldin.Nif(get), flags = 0},
  {name = "append", arity = 2, fptr = erldin.Nif(append_slot), flags = 0},
  {name = "to_list", arity = 1, fptr = erldin.Nif(to_list), flags = 0},
}

load :: proc "c" (env: ^erldin.Env, priv_data: [^]rawptr, load_info: erldin.Term) -> c.int {
  tried: erldin.ResourceFlags
  slots_resource_type = erldin.open_resource_type(
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
nif_init :: proc "c" () -> ^erldin.NifEntry {
  entry.major = 2
  entry.minor = 16
  entry.name = "Elixir.OdinNif.Slots"
  entry.funcs = raw_data(nif_functions[:])
  entry.num_of_funcs = len(nif_functions)
  entry.vm_variant = "beam.vanilla"
  entry.options = 1
  entry.sizeof_ErlNifResourceTypeInit = size_of(erldin.ResourceTypeInit)
  entry.min_erts = "erts-12.0"
  entry.load = erldin.LoadFunction(load)

  return &entry
}
