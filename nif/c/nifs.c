#include <erl_nif.h>
#include <stdio.h>

typedef struct {
  unsigned int size;
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
  ERL_NIF_TERM *data = malloc(1024 * sizeof(ERL_NIF_TERM));
  if (data == NULL) {
    return return_alloc_error(env);
  }

  Slots *slots = enif_alloc_resource(slots_resource_type, sizeof(Slots));
  slots->size = 1024;
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

static ERL_NIF_TERM hello(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  return enif_make_string(env, "Hello World from C!", ERL_NIF_LATIN1);
}

static ERL_NIF_TERM hello_binary(ErlNifEnv *env, int argc,
                                 const ERL_NIF_TERM argv[]) {
  int size = 0;

  if (!enif_get_int(env, argv[0], &size)) {
    return enif_make_badarg(env);
  }

  ErlNifBinary bin = {0};
  bin.data = malloc(size);
  bin.size = size;
  for (int i = 0; i < size; i++) {
    bin.data[i] = 'c';
  }

  ERL_NIF_TERM binary = enif_make_binary(env, &bin);

  free(bin.data);

  return binary;
}

static ERL_NIF_TERM hello_tuple(ErlNifEnv *env, int argc,
                                const ERL_NIF_TERM argv[]) {
  ERL_NIF_TERM first_argument = argv[0];

  int list_length = 0;
  if (!enif_get_int(env, argv[1], &list_length)) {
    return enif_make_badarg(env);
  }
  ERL_NIF_TERM *terms = malloc(list_length * sizeof(ERL_NIF_TERM));
  if (terms == NULL) {
    return enif_make_badarg(env);
  }

  for (int i = 0; i < list_length; i++) {
    terms[i] = enif_make_atom(env, "c");
  }

  ERL_NIF_TERM list =
      enif_make_list_from_array(env, terms, (unsigned int)list_length);

  return enif_make_tuple(env, 2, first_argument, list);
}

static ErlNifFunc nif_funcs[] = {
    {"hello", 0, hello},
    {"hello_binary", 1, hello_binary},
    {"hello_tuple", 2, hello_tuple},
    {"slots_create", 0, slots_create},
    {"slots_size", 1, slots_size},
    {"slots_set", 3, slots_set},
    {"slots_get", 2, slots_get},
};

static int load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info) {
  printf("loaded 'CNif' module\n");
  ErlNifResourceFlags tried;
  slots_resource_type =
      enif_open_resource_type(env, NULL, "Slots", slots_dtor,
                              ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER, &tried);

  if (slots_resource_type == NULL) {
    return -1;
  }

  return 0;
}

// int  (*load)   (ErlNifEnv*, void** priv_data, ERL_NIF_TERM load_info);
// int  (*reload) (ErlNifEnv*, void** priv_data, ERL_NIF_TERM load_info);
// int  (*upgrade)(ErlNifEnv*, void** priv_data, void** old_priv_data,
// ERL_NIF_TERM load_info); void (*unload) (ErlNifEnv*, void* priv_data);

ERL_NIF_INIT(Elixir.CNif, nif_funcs, load, NULL, NULL, NULL);
