# Set compiler
ERR = $(shell which clang >/dev/null; echo $$?)
ifeq "$(ERR)" "0"
    SC = clang
else
    SC = gcc
endif

# Force target choice
.PHONY:	default
.DEFAULT_GOAL: default
default:
	@echo "Please select a legitimate target:"
	@echo "	- debug"
	@echo "	- native"
	@echo "	- release"


# Optimization flags
MOFLAGS = -O2 -m64 -mpc64 -mfpmath=both
	# Unused flags
MOFLAGS	+= -Qunused-arguments
	# Constant propagation
MOFLAGS += -fipa-pta
	# Loop manipulation
MOFLAGS += -ftree-loop-linear -floop-interchange -floop-strip-mine
MOFLAGS += -floop-block -ftree-loop-distribution
MOFLAGS += -ftree-loop-distribute-patterns -funswitch-loops
	# Vectorization
MOFLAGS += -ftree-vectorize

CFLAGS = -pthread
debug:		CFLAGS += -Os -g -W
native:		CFLAGS += $(MOFLAGS) -w -march=native
release:	CFLAGS += $(MOFLAGS) -w -mtune=generic

HFLAGS = -Ibuild -I.
LFLAGS = -levent

HC = $(SC) $(HFLAGS)
CC = $(HC) $(CFLAGS)
LC = $(CC) $(LFLAGS)


# Final Targets
debug:		build/aixen
	date >> debug

native:		build/aixen
	date >> native

release:	build/aixen
	date >> release

# Generics
.PHONY:	all
all: default

build:
	mkdir -pv build

.PHONY: clean
clean:
	rm -rvf build debug native release

# Aixen
build/aixen:		build build/files_c
	$(LC) build/*.o -o build/aixen

build/files_c:		build build/aixen.o build/heartbeat.o build/control_pnl.o
	touch build/files_c

build/aixen.o:		build build/aixen.h.gch aixen.c
	$(CC) aixen.c -c -o build/aixen.o

build/control_pnl.o:	build build/aixen.o build/aixen.h.gch control_pnl.c
	$(CC) control_pnl.c -c -o build/control_pnl.o

build/heartbeat.o:	build build/aixen.h.gch heartbeat.c
	$(CC) heartbeat.c -c -o build/heartbeat.o

build/aixen.h.gch:	build aixen.h
	$(HC) aixen.h -o build/aixen.h.gch
