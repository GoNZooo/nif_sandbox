pub const erlang = @cImport({
    @cInclude("erl_nif.h");
});

pub fn makeEntry(
    name: [*c]const u8,
    functions: []erlang.ErlNifFunc,
    load: ?LoadFunction,
    reload: ?ReloadFunction,
    upgrade: ?UpgradeFunction,
    unload: ?UnloadFunction,
) erlang.ErlNifEntry {
    return erlang.ErlNifEntry{
        .major = erlang.ERL_NIF_MAJOR_VERSION,
        .minor = erlang.ERL_NIF_MINOR_VERSION,
        .name = name,
        .num_of_funcs = @intCast(c_int, functions.len),
        .funcs = functions.ptr,
        .load = load,
        .reload = reload,
        .upgrade = upgrade,
        .unload = unload,
        .vm_variant = "beam.vanilla",
        .options = 1,
        .sizeof_ErlNifResourceTypeInit = @sizeOf(erlang.ErlNifResourceTypeInit),
        .min_erts = "erts-10.4",
    };
}

const LoadFunction = extern fn (
    env: ?*erlang.ErlNifEnv,
    priv_data: [*c]?*c_void,
    load_info: erlang.ERL_NIF_TERM,
) c_int;

const ReloadFunction = extern fn (
    env: ?*erlang.ErlNifEnv,
    priv_data: [*c]?*c_void,
    load_info: erlang.ERL_NIF_TERM,
) c_int;

const UpgradeFunction = extern fn (
    env: ?*erlang.ErlNifEnv,
    priv_data: [*c]?*c_void,
    old_priv_data: [*c]?*c_void,
    load_info: erlang.ERL_NIF_TERM,
) c_int;

const UnloadFunction = extern fn (env: ?*erlang.ErlNifEnv, priv_data: ?*c_void) void;
