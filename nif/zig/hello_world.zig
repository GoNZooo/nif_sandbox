const nif_utilities = @import("./nif_utilities.zig");
const erl = nif_utilities.erl;

var entry: erl.ErlNifEntry = nif_utilities.makeEntry(
    "Elixir.HelloWorldInZig",
    nif_functions[0..],
    null,
    null,
    null,
    null,
);

export fn nif_init() *erl.ErlNifEntry {
    return &entry;
}

export fn hello(env: ?*erl.ErlNifEnv, argc: c_int, argv: [*c]const c_ulong) erl.ERL_NIF_TERM {
    return erl.enif_make_string(env, "Hello World from Zig!", erl.ErlNifCharEncoding.ERL_NIF_LATIN1);
}

var nif_functions = [_]erl.ErlNifFunc{
    erl.ErlNifFunc{ .name = "hello", .arity = 0, .fptr = hello, .flags = 0 },
};
