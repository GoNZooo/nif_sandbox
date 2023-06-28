const builtin = @import("std").builtin;

pub const erlang = @cImport({
    @cInclude("erl_nif.h");
});

pub fn makeEntry(
    name: [*c]const u8,
    functions: []erlang.ErlNifFunc,
    comptime load: LoadFunction,
    comptime reload: ReloadFunction,
    comptime upgrade: UpgradeFunction,
    comptime unload: UnloadFunction,
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

const LoadFunction = ?*const fn (?*erlang.ErlNifEnv, [*c]?*anyopaque, c_ulong) callconv(.C) c_int;

const ReloadFunction = ?*const fn (?*erlang.ErlNifEnv, [*c]?*anyopaque, c_ulong) callconv(.C) c_int;

const UpgradeFunction = ?*const fn (?*erlang.ErlNifEnv, [*c]?*anyopaque, [*c]?*anyopaque, c_ulong) callconv(.C) c_int;

const UnloadFunction = ?*const fn (?*erlang.ErlNifEnv, ?*anyopaque) callconv(.C) void;
