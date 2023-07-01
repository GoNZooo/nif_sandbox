const std = @import("std");
const heap = std.heap;
const nif_utilities = @import("nif_utilities.zig");
const erlang = nif_utilities.erlang;

var entry: erlang.ErlNifEntry = nif_utilities.makeEntry(
    "Elixir.ZigNif",
    nif_functions[0..],
    null,
    null,
    null,
    null,
);

export fn nif_init() *erlang.ErlNifEntry {
    return &entry;
}

fn hello(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argv;
    _ = argc;

    return erlang.enif_make_string(
        env,
        "Hello World from Zig!",
        erlang.ERL_NIF_LATIN1,
    );
}

fn helloBinary(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argc;

    var size: c_int = 0;
    if (erlang.enif_get_int(env, argv[0], &size) == 0) {
        return erlang.enif_make_badarg(env);
    }

    const allocator = heap.c_allocator;
    var data = allocator.alloc(u8, @intCast(usize, size)) catch unreachable;
    defer allocator.free(data);
    for (data) |*c| {
        c.* = 'z';
    }
    var binary = erlang.ErlNifBinary{
        .data = @ptrCast([*c]u8, data),
        .size = @intCast(usize, size),
        .ref_bin = null,
        .__spare__ = [2]?*anyopaque{ null, null },
    };

    return erlang.enif_make_binary(env, &binary);
}

fn helloTuple(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argc;

    const term_argument = argv[0];

    var list_size: c_int = 0;
    if (erlang.enif_get_int(env, argv[1], &list_size) == 0) {
        return erlang.enif_make_badarg(env);
    }

    const allocator = heap.c_allocator;
    var data = allocator.alloc(erlang.ERL_NIF_TERM, @intCast(usize, list_size)) catch unreachable;
    defer allocator.free(data);
    for (data) |*c| {
        c.* = erlang.enif_make_atom(env, "zig");
    }

    const list = erlang.enif_make_list_from_array(env, data.ptr, @intCast(c_uint, list_size));
    const tuple = erlang.enif_make_tuple(env, 2, term_argument, list);

    return tuple;
}

var nif_functions = [_]erlang.ErlNifFunc{
    erlang.ErlNifFunc{ .name = "hello", .arity = 0, .fptr = hello, .flags = 0 },
    erlang.ErlNifFunc{ .name = "hello_binary", .arity = 1, .fptr = helloBinary, .flags = 0 },
    erlang.ErlNifFunc{ .name = "hello_tuple", .arity = 2, .fptr = helloTuple, .flags = 0 },
};
