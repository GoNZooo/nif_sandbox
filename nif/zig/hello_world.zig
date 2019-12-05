// c version:
// #include <erl_nif.h>

// static ERL_NIF_TERM hello(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
// {
//     return enif_make_string(env, "Hello World!", ERL_NIF_LATIN1);
// }

// static ErlNifFunc nif_funcs[] = {"hello", 0, hello};

// ERL_NIF_INIT(Elixir.HelloWorld, nif_funcs, NULL, NULL, NULL, NULL);

const erl = @cImport({
    @cInclude("erl_nif.h");
});

export fn hello(env: ?*erl.ErlNifEnv, argc: c_int, argv: [*c]const c_ulong) erl.ERL_NIF_TERM {
    return erl.enif_make_string(env, "Hello World from Zig!", erl.ErlNifCharEncoding.ERL_NIF_LATIN1);
}

// `erl_nif.h` defines this function structure
// typedef struct enif_func_t
// {
//     const char* name;
//     unsigned arity;
//     ERL_NIF_TERM (*fptr)(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);
//     unsigned flags;
// }ErlNifFunc;

var nif_funcs = [_]erl.ErlNifFunc{erl.ErlNifFunc{
    .name = "hello",
    .arity = 0,
    .fptr = hello,
    .flags = 0,
}};

// This is the `erl_nif.h` entry specification; it's what's actually exported when you use
// `ERL_NIF_INIT(...)`:
// typedef struct enif_entry_t
// {
//     int major;
//     int minor;
//     const char* name;
//     int num_of_funcs;
//     ErlNifFunc* funcs;
//     int  (*load)   (ErlNifEnv*, void** priv_data, ERL_NIF_TERM load_info);
//     int  (*reload) (ErlNifEnv*, void** priv_data, ERL_NIF_TERM load_info);
//     int  (*upgrade)(ErlNifEnv*, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info);
//     void (*unload) (ErlNifEnv*, void* priv_data);

//     /* Added in 2.1 */
//     const char* vm_variant;

//     /* Added in 2.7 */
//     unsigned options;   /* Unused. Can be set to 0 or 1 (dirty sched config) */

//     /* Added in 2.12 */
//     size_t sizeof_ErlNifResourceTypeInit;

//     /* Added in 2.14 */
//     const char* min_erts;
// }ErlNifEntry;

const LoadFunction = extern fn (
    env: ?*erl.ErlNifEnv,
    priv_data: [*c]?*c_void,
    load_info: erl.ERL_NIF_TERM,
) c_int;
const ReloadFunction = extern fn (
    env: ?*erl.ErlNifEnv,
    priv_data: [*c]?*c_void,
    load_info: erl.ERL_NIF_TERM,
) c_int;

const UpgradeFunction = extern fn (
    env: ?*erl.ErlNifEnv,
    priv_data: [*c]?*c_void,
    old_priv_data: [*c]?*c_void,
    load_info: erl.ERL_NIF_TERM,
) c_int;

const UnloadFunction = extern fn (env: ?*erl.ErlNifEnv, priv_data: ?*c_void) c_int;

fn makeEntry(
    name: [*c]const u8,
    functions: c_int,
    load: ?LoadFunction,
    reload: ?ReloadFunction,
    upgrade: ?UpgradeFunction,
    unload: ?UnloadFunction,
) erl.ErlNifEntry {
    return erl.ErlNifEntry{
        .major = erl.ERL_NIF_MAJOR_VERSION,
        .minor = erl.ERL_NIF_MINOR_VERSION,
        .name = name,
        .num_of_funcs = functions,
        .funcs = &nif_funcs,
        .load = load,
        .reload = null,
        .upgrade = null,
        .unload = null,
        .vm_variant = "beam.vanilla",
        .options = 1,
        .sizeof_ErlNifResourceTypeInit = @sizeOf(erl.ErlNifResourceTypeInit),
        .min_erts = "erts-10.4",
    };
}

var entry: erl.ErlNifEntry = makeEntry("Elixir.HelloWorldInZig", 1, null, null, null, null);

export fn nif_init() *erl.ErlNifEntry {
    return &entry;
}
