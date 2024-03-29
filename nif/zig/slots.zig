const std = @import("std");
const heap = std.heap;
const mem = std.mem;
const debug = std.debug;
const nif_utilities = @import("nif_utilities.zig");
const erlang = nif_utilities.erlang;

const Slots = struct {
    slots: []erlang.ERL_NIF_TERM,
    size: usize,
    allocator: mem.Allocator,

    pub fn init(allocator: mem.Allocator) !Slots {
        var slots = try allocator.alloc(erlang.ERL_NIF_TERM, 1);

        return Slots{
            .slots = slots,
            .size = 1,
            .allocator = allocator,
        };
    }

    pub fn set(self: *Slots, index: usize, term: erlang.ERL_NIF_TERM) !void {
        if (index >= self.slots.len) {
            return error.IndexOutOfBounds;
        }

        self.slots[index] = term;
    }

    pub fn get(self: *Slots, index: usize) !erlang.ERL_NIF_TERM {
        if (index >= self.slots.len) {
            return error.IndexOutOfBounds;
        }

        return self.slots[index];
    }

    pub fn deinit(self: *Slots) void {
        self.allocator.free(self.slots);
    }
};

fn slotsDestructor(env: ?*erlang.ErlNifEnv, obj: ?*anyopaque) callconv(.C) void {
    _ = env;
    if (obj == null) {
        return;
    }
    var slots: *Slots = @ptrCast(*Slots, @alignCast(@alignOf(Slots), obj.?));
    slots.deinit();
}

var slots_resource_type: ?*erlang.ErlNifResourceType = null;

fn create(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argv;
    _ = argc;

    var allocator = heap.c_allocator;
    var slots = Slots.init(allocator) catch |e| switch (e) {
        error.OutOfMemory => {
            return erlang.enif_make_tuple(
                env,
                2,
                erlang.enif_make_atom(env, "error"),
                erlang.enif_make_atom(env, "alloc_error"),
            );
        },
    };
    for (slots.slots) |*slot| {
        slot.* = erlang.enif_make_atom(env, "unset");
    }

    var resource = @ptrCast(
        *Slots,
        @alignCast(
            @alignOf(*Slots),
            erlang.enif_alloc_resource(
                slots_resource_type,
                @sizeOf(Slots),
            ),
        ),
    );
    defer erlang.enif_release_resource(resource);
    resource.* = slots;
    var term = erlang.enif_make_resource(env, resource);

    return erlang.enif_make_tuple(env, 2, erlang.enif_make_atom(env, "ok"), term);
}

fn size(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argc;
    var slots: *Slots = undefined;
    if (erlang.enif_get_resource(
        env,
        argv[0],
        slots_resource_type.?,
        @ptrCast([*c]?*anyopaque, &slots),
    ) == 0) {
        return erlang.enif_make_badarg(env);
    }

    return erlang.enif_make_int(env, @intCast(c_int, slots.size));
}

fn capacity(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argc;
    var slots: *Slots = undefined;
    if (erlang.enif_get_resource(
        env,
        argv[0],
        slots_resource_type.?,
        @ptrCast([*c]?*anyopaque, &slots),
    ) == 0) {
        return erlang.enif_make_badarg(env);
    }

    return erlang.enif_make_int(env, @intCast(c_int, slots.slots.len));
}

fn reserve(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argc;
    var slots: *Slots = undefined;
    if (erlang.enif_get_resource(
        env,
        argv[0],
        slots_resource_type.?,
        @ptrCast([*c]?*anyopaque, &slots),
    ) == 0) {
        return erlang.enif_make_badarg(env);
    }

    var requested_capacity: c_int = 0;
    if (erlang.enif_get_int(env, argv[1], &requested_capacity) == 0) {
        return erlang.enif_make_badarg(env);
    }

    if (requested_capacity <= slots.slots.len) {
        return erlang.enif_make_atom(env, "ok");
    }

    var new_slots = slots.allocator.realloc(
        slots.slots,
        @intCast(usize, requested_capacity),
    ) catch |e| switch (e) {
        error.OutOfMemory => {
            return erlang.enif_make_tuple(
                env,
                2,
                erlang.enif_make_atom(env, "error"),
                erlang.enif_make_atom(env, "alloc_error"),
            );
        },
    };
    slots.slots = new_slots;

    return erlang.enif_make_atom(env, "ok");
}
fn set(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argc;
    var slots: *Slots = undefined;
    if (erlang.enif_get_resource(
        env,
        argv[0],
        slots_resource_type.?,
        @ptrCast([*c]?*anyopaque, &slots),
    ) == 0) {
        return erlang.enif_make_badarg(env);
    }

    var index: c_int = 0;
    if (erlang.enif_get_int(env, argv[1], &index) == 0) {
        return erlang.enif_make_badarg(env);
    }

    var term = argv[2];

    slots.set(@intCast(usize, index), term) catch |e| switch (e) {
        error.IndexOutOfBounds => {
            return erlang.enif_make_tuple(
                env,
                2,
                erlang.enif_make_atom(env, "error"),
                erlang.enif_make_atom(env, "index_out_of_bounds"),
            );
        },
    };

    return erlang.enif_make_atom(env, "ok");
}

fn get(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argc;
    var slots: *Slots = undefined;
    if (erlang.enif_get_resource(
        env,
        argv[0],
        slots_resource_type.?,
        @ptrCast([*c]?*anyopaque, &slots),
    ) == 0) {
        return erlang.enif_make_badarg(env);
    }

    var index: c_int = 0;
    if (erlang.enif_get_int(env, argv[1], &index) == 0) {
        return erlang.enif_make_badarg(env);
    }

    var term = slots.get(@intCast(usize, index)) catch |e| switch (e) {
        error.IndexOutOfBounds => {
            return erlang.enif_make_tuple(
                env,
                2,
                erlang.enif_make_atom(env, "error"),
                erlang.enif_make_atom(env, "index_out_of_bounds"),
            );
        },
    };

    return erlang.enif_make_tuple(env, 2, erlang.enif_make_atom(env, "ok"), term);
}

fn append(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argc;
    var slots: *Slots = undefined;
    if (erlang.enif_get_resource(
        env,
        argv[0],
        slots_resource_type.?,
        @ptrCast([*c]?*anyopaque, &slots),
    ) == 0) {
        return erlang.enif_make_badarg(env);
    }

    var term = argv[1];

    if (slots.size == slots.slots.len) {
        slots.slots = slots.allocator.realloc(slots.slots, slots.slots.len * 2) catch |e| switch (e) {
            error.OutOfMemory => {
                return erlang.enif_make_tuple(
                    env,
                    2,
                    erlang.enif_make_atom(env, "error"),
                    erlang.enif_make_atom(env, "alloc_error"),
                );
            },
        };
    }
    slots.slots[slots.size] = term;
    slots.size += 1;

    return erlang.enif_make_atom(env, "ok");
}

fn toList(
    env: ?*erlang.ErlNifEnv,
    argc: c_int,
    argv: [*c]const erlang.ERL_NIF_TERM,
) callconv(.C) erlang.ERL_NIF_TERM {
    _ = argc;
    var slots: *Slots = undefined;
    if (erlang.enif_get_resource(
        env,
        argv[0],
        slots_resource_type.?,
        @ptrCast([*c]?*anyopaque, &slots),
    ) == 0) {
        return erlang.enif_make_badarg(env);
    }

    return erlang.enif_make_list_from_array(env, slots.slots.ptr, @intCast(c_uint, slots.size));
}

var entry: erlang.ErlNifEntry = nif_utilities.makeEntry(
    "Elixir.ZigNif.Slots",
    nifs[0..],
    load,
    null,
    null,
    null,
);

export fn nif_init() *erlang.ErlNifEntry {
    return &entry;
}

fn load(
    env: ?*erlang.ErlNifEnv,
    priv_data: [*c]?*anyopaque,
    load_info: erlang.ERL_NIF_TERM,
) callconv(.C) c_int {
    _ = load_info;
    _ = priv_data;
    var tried: erlang.ErlNifResourceFlags = 0;
    const resource_open_result = erlang.enif_open_resource_type(
        env,
        null,
        "ZigSlots",
        slotsDestructor,
        erlang.ERL_NIF_RT_CREATE | erlang.ERL_NIF_RT_TAKEOVER,
        &tried,
    );
    if (resource_open_result == null) {
        return -1;
    }

    slots_resource_type = resource_open_result;

    return 0;
}

var nifs = [_]erlang.ErlNifFunc{
    erlang.ErlNifFunc{ .name = "create", .arity = 0, .fptr = create, .flags = 0 },
    erlang.ErlNifFunc{ .name = "size", .arity = 1, .fptr = size, .flags = 0 },
    erlang.ErlNifFunc{ .name = "capacity", .arity = 1, .fptr = capacity, .flags = 0 },
    erlang.ErlNifFunc{ .name = "reserve", .arity = 2, .fptr = reserve, .flags = 0 },
    erlang.ErlNifFunc{ .name = "set", .arity = 3, .fptr = set, .flags = 0 },
    erlang.ErlNifFunc{ .name = "get", .arity = 2, .fptr = get, .flags = 0 },
    erlang.ErlNifFunc{ .name = "append", .arity = 2, .fptr = append, .flags = 0 },
    erlang.ErlNifFunc{ .name = "to_list", .arity = 1, .fptr = toList, .flags = 0 },
};
