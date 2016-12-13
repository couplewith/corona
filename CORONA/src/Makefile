
CC = gcc
LIBDIR = -L/usr/local/lib
COMMON_LIBS = -lnetsnmp -lcrypto -lm
CFLAGS = -I/usr/local/include

SRC = Corona.c

all : Corona install

Corona  : Corona.o
	${CC} ${CFLAGS} -o $@ Corona.o $(LIBDIR) ${COMMON_LIBS} 

install  : Corona
	cp Corona ../../bin

clean : 
	rm -rf *.o
