FLAGS=--library c -dynamic -fPIC 
NAME=libzig_hello_world
NIF_DIR=nif
OBJ_DIR=$(NIF_DIR)/obj
ZIG_OUT_DIR=$(OBJ_DIR)/zig
ZIG_NIF_BUILD=zig build-lib $(FLAGS) -I $(ERL_HEADERS) -femit-bin=$(ZIG_OUT_DIR)/$(NAME).so
C_OUT_DIR=$(OBJ_DIR)/c
C_NIF_BUILD=gcc -fpic -shared -I $(ERL_HEADERS) -o $(C_OUT_DIR)/hello_world.so

nif: hello_world.zig hello_world.c

hello_world.zig:
	mkdir -p $(ZIG_OUT_DIR)
	$(ZIG_NIF_BUILD) $(NIF_DIR)/zig/$@

hello_world.c:
	mkdir -p $(C_OUT_DIR)
	$(C_NIF_BUILD) $(NIF_DIR)/c/$@

clean:
	rm -rf $(OBJ_DIR)
	
