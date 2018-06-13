CC = gcc
CFLAGS = -lgmp -lbsd

.PHONY: all
all: dirs execs

.PHONY: dirs
dirs:
	@mkdir -p bin build

execs: bin/decrypt_key bin/encrypt_key bin/square_tester bin/key_gen bin/fpga_square_tester bin/fpga_ratio_analyze

bin/%: src/%.c build/math.o
	$(CC) $^ -o $@ $(CFLAGS)

build/math.o: src/math.c src/math.h
	$(CC) $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -rf bin build