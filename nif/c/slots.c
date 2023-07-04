#include <erl_nif.h>
#include <stdio.h>

typedef struct {
  unsigned int size;
  unsigned int capacity;
  ERL_NIF_TERM *data;
} Slots;

ErlNifResourceType *slots_resource_type;

static void slots_dtor(ErlNifEnv *env, void *obj) {
  // printf("Running dtor for 'Slots' resource\n");
  Slots *slots = (Slots *)obj;
  free(slots->data);
}

static ERL_NIF_TERM return_alloc_error(ErlNifEnv *env) {
  return enif_make_tuple(env, 2, enif_make_atom(env, "error"),
                         enif_make_atom(env, "alloc_error"));
}

static ERL_NIF_TERM slots_create(ErlNifEnv *env, int argc,
                                 const ERL_NIF_TERM argv[]) {
  ERL_NIF_TERM *data = malloc(1 * sizeof(ERL_NIF_TERM));
  if (data == NULL) {
    return return_alloc_error(env);
  }
  data[0] = enif_make_atom(env, "unset");

  Slots *slots = enif_alloc_resource(slots_resource_type, sizeof(Slots));
  slots->size = 1;
  slots->capacity = 1;
  slots->data = data;

  ERL_NIF_TERM slots_term = enif_make_resource(env, slots);
  enif_release_resource(slots);

  return enif_make_tuple(env, 2, enif_make_atom(env, "ok"), slots_term);
}

static ERL_NIF_TERM slots_size(ErlNifEnv *env, int argc,
                               const ERL_NIF_TERM argv[]) {
  Slots *slots;
  if (!enif_get_resource(env, argv[0], slots_resource_type, (void **)&slots)) {
    return enif_make_badarg(env);
  }

  return enif_make_int(env, slots->size);
}

static ERL_NIF_TERM slots_capacity(ErlNifEnv *env, int argc,
                                   const ERL_NIF_TERM argv[]) {
  Slots *slots;
  if (!enif_get_resource(env, argv[0], slots_resource_type, (void **)&slots)) {
    return enif_make_badarg(env);
  }

  return enif_make_int(env, slots->capacity);
}

static ERL_NIF_TERM slots_set(ErlNifEnv *env, int argc,
                              const ERL_NIF_TERM argv[]) {
  Slots *slots;
  if (!enif_get_resource(env, argv[0], slots_resource_type, (void **)&slots)) {
    return enif_make_badarg(env);
  }

  int index = 0;
  if (!enif_get_int(env, argv[1], &index)) {
    return enif_make_badarg(env);
  }

  if (index >= slots->size) {
    return enif_make_badarg(env);
  }

  slots->data[index] = argv[2];

  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM slots_get(ErlNifEnv *env, int argc,
                              const ERL_NIF_TERM argv[]) {
  Slots *slots;
  if (!enif_get_resource(env, argv[0], slots_resource_type, (void **)&slots)) {
    return enif_make_badarg(env);
  }

  int index = 0;
  if (!enif_get_int(env, argv[1], &index)) {
    return enif_make_badarg(env);
  }

  if (index >= slots->size) {
    return enif_make_tuple(env, 2, enif_make_atom(env, "error"),
                           enif_make_atom(env, "index_out_of_bounds"));
  }

  return enif_make_tuple(env, 2, enif_make_atom(env, "ok"), slots->data[index]);
}

static ERL_NIF_TERM slots_append(ErlNifEnv *env, int argc,
                                 const ERL_NIF_TERM argv[]) {
  Slots *slots;
  if (!enif_get_resource(env, argv[0], slots_resource_type, (void **)&slots)) {
    return enif_make_badarg(env);
  }

  ERL_NIF_TERM value = argv[1];

  if (slots->size == slots->capacity) {
    unsigned int new_capacity = slots->capacity * 2;
    ERL_NIF_TERM *new_data =
        realloc(slots->data, new_capacity * sizeof(ERL_NIF_TERM));
    if (new_data == NULL) {
      return return_alloc_error(env);
    }
    slots->data = new_data;
    slots->capacity = new_capacity;
  }
  slots->data[slots->size] = value;
  slots->size++;

  return enif_make_atom(env, "ok");
}

static ErlNifFunc nifs[] = {
    {"create", 0, slots_create},     {"size", 1, slots_size},
    {"capacity", 1, slots_capacity}, {"set", 3, slots_set},
    {"get", 2, slots_get},           {"append", 2, slots_append},
};

static int load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info) {
  ErlNifResourceFlags tried;
  slots_resource_type =
      enif_open_resource_type(env, NULL, "CSlots", slots_dtor,
                              ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER, &tried);

  if (slots_resource_type == NULL) {
    return -1;
  }

  return 0;
}

ERL_NIF_INIT(Elixir.CNif.Slots, nifs, load, NULL, NULL, NULL);
