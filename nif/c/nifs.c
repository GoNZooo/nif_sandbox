#include <erl_nif.h>
#include <stdio.h>

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
};

ERL_NIF_INIT(Elixir.CNif, nif_funcs, NULL, NULL, NULL, NULL);
