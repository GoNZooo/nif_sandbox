const erl = @cImport({
    @cInclude("erl_nif.h");
});

var entry: erl.ErlNifEntry = makeEntry("Elixir.HelloWorldInZig", 1, null, null, null, null);

export fn nif_init() *erl.ErlNifEntry {
    return &entry;
}

export fn hello(env: ?*erl.ErlNifEnv, argc: c_int, argv: [*c]const c_ulong) erl.ERL_NIF_TERM {
    return erl.enif_make_string(env, "Hello World from Zig!", erl.ErlNifCharEncoding.ERL_NIF_LATIN1);
}

var nif_funcs = [_]erl.ErlNifFunc{erl.ErlNifFunc{
    .name = "hello",
    .arity = 0,
    .fptr = hello,
    .flags = 0,
}};

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
        .reload = reload,
        .upgrade = upgrade,
        .unload = unload,
        .vm_variant = "beam.vanilla",
        .options = 1,
        .sizeof_ErlNifResourceTypeInit = @sizeOf(erl.ErlNifResourceTypeInit),
        .min_erts = "erts-10.4",
    };
}

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

const UnloadFunction = extern fn (env: ?*erl.ErlNifEnv, priv_data: ?*c_void) void;
