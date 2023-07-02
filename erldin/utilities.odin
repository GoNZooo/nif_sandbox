package erldin

import "core:mem"
import "core:c"

Paths :: struct {
  include: string,
  lib:     string,
}

FindPathsError :: union {
  mem.Allocator_Error,
  NoEnvironmentVariableSet,
}

NoEnvironmentVariableSet :: struct {
  key: string,
}

// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_binary,(ErlNifEnv* env, ErlNifBinary* bin));
// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_badarg,(ErlNifEnv* env));
// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_int,(ErlNifEnv* env, int i));
// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_ulong,(ErlNifEnv* env, unsigned long i));
// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_double,(ErlNifEnv* env, double d));
// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_atom,(ErlNifEnv* env, const char* name));
// ERL_NIF_API_FUNC_DECL(int,enif_make_existing_atom,(ErlNifEnv* env, const char* name, ERL_NIF_TERM* atom, ErlNifCharEncoding));
// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_tuple,(ErlNifEnv* env, unsigned cnt, ...));
// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_list,(ErlNifEnv* env, unsigned cnt, ...));
// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_list_cell,(ErlNifEnv* env, ERL_NIF_TERM car, ERL_NIF_TERM cdr));
// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_string,(ErlNifEnv* env, const char* string, ErlNifCharEncoding));
// ERL_NIF_API_FUNC_DECL(ERL_NIF_TERM,enif_make_ref,(ErlNifEnv* env));

// #  define enif_get_int ERL_NIF_API_FUNC_MACRO(enif_get_int)
// #  define enif_get_ulong ERL_NIF_API_FUNC_MACRO(enif_get_ulong)
// #  define enif_get_double ERL_NIF_API_FUNC_MACRO(enif_get_double)
// #  define enif_get_tuple ERL_NIF_API_FUNC_MACRO(enif_get_tuple)
// #  define enif_get_list_cell ERL_NIF_API_FUNC_MACRO(enif_get_list_cell)

foreign import erldin "erldin_nif.h"
foreign erldin {
  enif_make_binary :: proc(env: ^ErlNifEnv, bin: ^ErlNifBinary) -> ERL_NIF_TERM ---
  enif_make_badarg :: proc(env: ^ErlNifEnv) -> ERL_NIF_TERM ---
  enif_make_int :: proc(env: ^ErlNifEnv, i: c.int) -> ERL_NIF_TERM ---
  enif_make_ulong :: proc(env: ^ErlNifEnv, i: c.ulong) -> ERL_NIF_TERM ---
  enif_make_double :: proc(env: ^ErlNifEnv, d: c.double) -> ERL_NIF_TERM ---
  enif_make_atom :: proc(env: ^ErlNifEnv, name: cstring) -> ERL_NIF_TERM ---
  enif_make_existing_atom :: proc(env: ^ErlNifEnv, name: cstring, atom: ^ERL_NIF_TERM, encoding: c.uint) -> c.int ---
  enif_make_tuple :: proc(env: ^ErlNifEnv, n: c.uint, #c_vararg terms: ..ERL_NIF_TERM) -> ERL_NIF_TERM ---
  enif_make_list_from_array :: proc(env: ^ErlNifEnv, array: [^]ERL_NIF_TERM, count: c.uint) -> ERL_NIF_TERM ---
  enif_make_string :: proc(env: ^ErlNifEnv, string: cstring, encoding: c.uint) -> ERL_NIF_TERM ---

  enif_get_int :: proc(env: ^ErlNifEnv, term: ERL_NIF_TERM, ip: ^c.int) -> b32 ---
  enif_get_resource :: proc(env: ^ErlNifEnv, term: ERL_NIF_TERM, resource_type: ^ResourceType, obj: ^rawptr) -> b32 ---

  // Resources
  enif_open_resource_type :: proc(env: ^ErlNifEnv, module: cstring, name: cstring, destructor: ResourceDestructor, flags: ResourceFlags, tried: ^ResourceFlags) -> ^ResourceType ---
  enif_alloc_resource :: proc(resource_type: ^ResourceType, size: c.size_t) -> ^rawptr ---
  enif_make_resource :: proc(env: ^ErlNifEnv, resource: ^rawptr) -> ERL_NIF_TERM ---
  enif_release_resource :: proc(resource: ^rawptr) ---
}

ErlNifBinary :: struct {
  size:      c.size_t,
  data:      [^]u8,
  ref_bin:   rawptr,
  __spare__: [2]rawptr,
}

ResourceType :: distinct rawptr

ResourceFlags :: enum {
  CREATE   = 1,
  TAKEOVER = 2,
}

// typedef void ErlNifResourceDtor(ErlNifEnv*, void*);
// typedef void ErlNifResourceStop(ErlNifEnv*, void*, ErlNifEvent, int is_direct_call);
// typedef void ErlNifResourceDown(ErlNifEnv*, void*, ErlNifPid*, ErlNifMonitor*);
// typedef void ErlNifResourceDynCall(ErlNifEnv*, void* obj, void* call_data);

ResourceDestructor :: proc(env: ^ErlNifEnv, resource: ^rawptr)

ErlNifResourceTypeInit :: struct {
  dtor:    ResourceDestructor,
  stop:    rawptr,
  down:    rawptr,
  members: c.int,
  dyncall: rawptr,
}

ErlNifEntry :: struct {
  major:                         c.int,
  minor:                         c.int,
  name:                          cstring,
  num_of_funcs:                  c.int,
  funcs:                         [^]ErlNifFunc,
  load:                          LoadFunction,
  reload:                        ReloadFunction,
  upgrade:                       UpgradeFunction,
  unload:                        UnloadFunction,
  vm_variant:                    cstring,
  options:                       c.uint,
  sizeof_ErlNifResourceTypeInit: c.size_t,
  min_erts:                      cstring,
}

ErlNifEnv :: rawptr

ERL_NIF_TERM :: u64

LoadFunction :: proc(env: ^ErlNifEnv, priv_data: [^]rawptr, load_info: ERL_NIF_TERM) -> c.int

ReloadFunction :: proc(env: ^ErlNifEnv, priv_data: [^]rawptr, load_info: ERL_NIF_TERM) -> c.int

UpgradeFunction :: proc(
  env: ^ErlNifEnv,
  priv_data: [^]rawptr,
  old_priv_data: [^]rawptr,
  load_info: ERL_NIF_TERM,
) -> c.int

UnloadFunction :: proc(env: ^ErlNifEnv, priv_data: rawptr)

ErlNifFunc :: struct {
  name:  cstring,
  arity: c.uint,
  fptr:  Nif,
  flags: c.uint,
}

Nif :: proc(env: ^ErlNifEnv, argc: c.int, argv: [^]ERL_NIF_TERM) -> ERL_NIF_TERM

encoding :: enum u32 {
  ERL_NIF_LATIN1 = 1,
}
