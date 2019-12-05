FLAGS=--disable-gen-h --library c -dynamic -fPIC 
ERL_HEADERS=/usr/lib/erlang/usr/include/
NAME=zig_hello_world
NIF_DIR=nif
OBJ_DIR=$(NIF_DIR)/obj
ZIG_OUT_DIR=$(OBJ_DIR)/zig
ZIG_NIF_BUILD=zig build-lib $(FLAGS) -I $(ERL_HEADERS) --output-dir $(ZIG_OUT_DIR) --name $(NAME)
C_OUT_DIR=$(OBJ_DIR)/c
C_NIF_BUILD=gcc -fPIC -shared -I $(ERL_HEADERS) -o $(C_OUT_DIR)/hello_world.so 

nif: hello_world.zig hello_world.c
	mv $(ZIG_OUT_DIR)/libzig_hello_world.so.0.0.0 $(ZIG_OUT_DIR)/libzig_hello_world.so

%.zig:
	$(ZIG_NIF_BUILD) $(NIF_DIR)/zig/$@

%.c:
	mkdir -p $(C_OUT_DIR)
	$(C_NIF_BUILD) $(NIF_DIR)/c/$@

clean:
	rm -rf $(OBJ_DIR)
	