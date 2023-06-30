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

export fn hello(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const c_ulong,
) erlang.ERL_NIF_TERM {
    _ = argv;
    _ = argc;

    return erlang.enif_make_string(
        env,
        "Hello World from Zig!",
        erlang.ERL_NIF_LATIN1,
    );
}

var nif_functions = [_]erlang.ErlNifFunc{
    erlang.ErlNifFunc{ .name = "hello", .arity = 0, .fptr = hello, .flags = 0 },
};
