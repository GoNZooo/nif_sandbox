// #include <stdio.h>
#include <erl_nif.h>

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

static ErlNifFunc nif_funcs[] = {{"hello", 0, hello},
                                 {"hello_binary", 1, hello_binary}};

ERL_NIF_INIT(Elixir.CNif, nif_funcs, NULL, NULL, NULL, NULL);
