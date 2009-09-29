CSRCS=$(shell ls src/c/*.c)
COBJS=$(CSRCS:.c=.o)
INCLUDES=$(shell ls include/c/*.h)

# first CFLAGS is for a debug build, second is for a 'prod' build
#CFLAGS=-Wall -Werror -std=c99 -Iinclude/c -g -DDEBUG -O0
CFLAGS=-Wall -Werror -std=c99 -Iinclude/c

LIBBREW=target/libbrew.dylib
TEST=target/test
TESTOBJ=test/src/c/test.o
LD_LIBRARY_PATH=target:src/chicken
CHICKEN_BREW=src/chicken/brew.dylib

all: $(CHICKEN_BREW) run-test

$(CHICKEN_BREW): src/chicken/brew.scm $(CSRCS) $(INCLUDES) $(LIBBREW)
	csc -shared -Iinclude/c -Ltarget -Lsrc/chicken -lbrew src/chicken/brew.scm
#	chicken-setup -keep -n -csc-option "-Iinclude/c -Ltarget -Lsrc/chicken -lbrew" src/chicken/brew.scm


run-test: $(LIBBREW) $(TEST) $(CHICKEN_BREW)
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) csi -I src/chicken -q test/src/chicken/test.scm -e '(execute-tests)'
#	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) target/test

csi: $(LIBBREW) $(TEST) $(CHICKEN_BREW)
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) csi -I src/chicken -q test/src/chicken/test.scm

valgrind-test: $(LIBBREW) $(TEST)
	LD_LIBRARY_PATH=target valgrind $(VALGRIND_OPTS) target/test

$(LIBBREW): $(COBJS)
	$(LD) $(LDFLAGS) -dylib $(COBJS) -o $(LIBBREW) -lc
#	$(CC) $(LDFLAGS) -shared $(COBJS) -o $(LIBBREW) -lc

$(TEST): $(COBJS) $(LIBBREW) $(TESTOBJ)
	$(CC) $(LDFLAGS) -o $(TEST) $(TESTOBJ) -Ltarget -Lsrc/chicken -lbrew -lm

$(CSRCS): $(INCLUDES)

clean:
	-rm $(COBJS) $(LIBBREW) $(TEST) $(TESTOBJ)
