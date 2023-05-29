objects = azerty br chloe colemak dvorak es jcuken qwertz us
all: $(objects)

$(objects): %: %.c
	$(CC) $(CFLAGS) -o $@.o $<

clean:
	rm -f *.o

install: $(eval SHELL:=/bin/bash)
	./azerty.o
	./br.o
	./chloe.o
	./colemak.o
	./dvorak.o
	./es.o
	./jcuken.o
	./qwertz.o
	./us.o
	make clean
