SHELL=/bin/bash

################################################################################
# Assuming you have a folder 'alias' with the following test files:
#
# alias/
# 	main.d      (benchmark evaluator)
# 	test_1.d    (provides a test, must be annotated with `extern`)
# 	test_2.d
# 	...
#
# it then provides the following targets
#
# make alias.dmd
# make alias.ldc
# make alias.all
#
# Other targets
# -------------
#
# make all     (will run all targets)
# make clean   (removes all binaries)
################################################################################

################################################################################
# Flags
################################################################################

DMD_FLAGS=-inline -release -O -boundscheck=off
LDC_FLAGS=-release -O3 -boundscheck=off
# if gcc > 6, you can try -fbounds-check=off
GDC_FLAGS=-finline-functions -frelease -O3

MIR_PATH=..
MIR_SOURCE=$(MIR_PATH)/source
GFLAGS=-I$(MIR_SOURCE)

################################################################################
# Compilers
################################################################################

DMD=dmd
LDC=ldc
GDC=gdc

# included in the DMD Linux release
OBJ2ASM=~/programs/dmd2/linux/bin64/obj2asm

bin/%/:
	mkdir -p $@

################################################################################
# Libraries
################################################################################

bin/dmd/libmir.a: | bin/dmd/
	$(DMD) $(DMD_FLAGS) -lib -of$@ $$(find $(MIR_SOURCE) -name '*.d')

bin/ldc/libmir.a: | bin/ldc/
	$(LDC) $(LDC_FLAGS) -lib -of$@ $$(find $(MIR_SOURCE) -name '*.d')

################################################################################
# Optimized object files
################################################################################

bin/dmd/%.o: %.d | bin/dmd/
	$(DMD) $(GFLAGS) $(DMD_FLAGS) -c $< -of$@

bin/ldc/%.o: %.d | bin/ldc/
	$(LDC) $(GFLAGS) $(LDC_FLAGS) -c $< -of$@

################################################################################
# Main object files (unoptimized)
################################################################################

bin/dmd/%/main.o: %/main.d | bin/dmd/
	$(DMD) $(DMD_FLAGS) $(GFLAGS) -I$(subst bin/dmd/,,$(@D)) -c $< -of$@

bin/ldc/%/main.o: %/main.d | bin/ldc/
	$(LDC) $(LDC_FLAGS) $(GFLAGS) -I$(subst bin/ldc/,,$(@D)) -c $< -of$@

################################################################################
# Assembler files
# e.g. `make bin/dmd/alias/test_1.s`
################################################################################

bin/dmd/%.s: bin/dmd/%.o
	$(OBJ2ASM) $< > $@

bin/ldc/%.s: %.d
	$(LDC) $(GFLAGS) $(LDC_FLAGS) -c -output-s $< -of$@

################################################################################
# Link to binary
################################################################################

.SECONDEXPANSION:

bin/dmd/run_%: $$(subst .d,.o, $$(addprefix bin/dmd/, $$(wildcard $$(*F)/*.d))) bin/dmd/libmir.a
	$(DMD) -of$@ $^

bin/ldc/run_%: $$(subst .d,.o, $$(addprefix bin/ldc/, $$(wildcard $$(*F)/*.d))) bin/ldc/libmir.a
	$(LDC) -of$@ $^

################################################################################
# Global targets
################################################################################

%.all: %.dmd %.ldc
	@echo

%.dmd: bin/dmd/run_%
	@echo ">dmd"
	@$<

%.ldc: bin/ldc/run_%
	@echo ">ldc"
	@$<

all: $(subst /,.all, $(filter-out bin/,$(wildcard */)))

################################################################################
# Other
################################################################################

clean:
	rm -rf bin

MAKEFLAGS += --no-builtin-rules

# Save intermediate files during development (remove for production)
.SECONDARY:
