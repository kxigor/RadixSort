# Compiler
CC = gcc
ASM = nasm

# Program name
PNAME = radix.o

#Tests generator name
TNAME = tests_generator.o

# Flags
CFLAGS = -z noexecstack

# Fast Flags
#CFLAGS += -O3 -DNDEBUG

# Debugging Flags
CFLAGS += -D _DEBUG -ggdb3 -Wall -Wextra -Waggressive-loop-optimizations -Wmissing-declarations -Wcast-align -Wcast-qual -Wchar-subscripts -Wconversion -Wempty-body -Wfloat-equal -Wformat-nonliteral -Wformat-security -Wformat-signedness -Wformat=2 -Winline -Wlogical-op -Wopenmp-simd -Wpacked -Wpointer-arith -Winit-self -Wredundant-decls -Wshadow -Wsign-conversion -Wstrict-overflow=2 -Wsuggest-attribute=noreturn -Wsuggest-final-methods -Wsuggest-final-types -Wswitch-default -Wswitch-enum -Wsync-nand -Wundef -Wunreachable-code -Wunused -Wvariadic-macros -Wno-missing-field-initializers -Wno-narrowing -Wno-varargs -Wstack-protector -fcheck-new -fstack-protector -fstrict-overflow -flto-odr-type-merging -fno-omit-frame-pointer -Wlarger-than=8192 -Wstack-usage=8192 -pie -fPIE -Werror=vla -fsanitize=address,alignment,bool,bounds,enum,float-cast-overflow,float-divide-by-zero,integer-divide-by-zero,leak,nonnull-attribute,null,object-size,return,returns-nonnull-attribute,shift,signed-integer-overflow,undefined,unreachable,vla-bound,vptr

# GDB Flags
GDBFLAGS = -g

# Objects Dir
OBJ_DIR = obj

# Tests Formats Dir
FORMATS_DIR = src/tests/tests_formats

# Sources
SRCS  = main.c
SRCS += src/radix_uint64/radix_uint64.c
SRCS += src/radix_flt/radix_flt.c

SRCS_ASM  = src/radix_asm_uint64/radix_asm_uint64.asm
SRCS_ASM += src/radix_asm_flt/radix_asm_flt.asm

SRCS_TESTS  = src/tests/tests_generator/tests_generator.c
SRCS_TESTS += src/dirs/dirs.c

OBJS  = $(SRCS:.c=.o)
OBJS += $(SRCS_ASM:.asm=.o)

OBJS_TESTS = $(SRCS_TESTS:.c=.o)

%.o: %.c
	@mkdir -p $(dir $(OBJ_DIR)/$@)
	@$(CC) $(CFLAGS) $(GDBFLAGS) -c $< -o $(OBJ_DIR)/$@ -lm
%.o: %.asm
	@mkdir -p $(dir $(OBJ_DIR)/$@)
	@$(ASM) -f elf64 $(GDBFLAGS) $< -o $(OBJ_DIR)/$@
compile: $(OBJS)
	@$(CC) $(CFLAGS) $(patsubst %,obj/%,$(OBJS)) -o $(PNAME) -lm -no-pie

TSTS  = $(FORMATS_DIR)/1.txt
TSTS += $(FORMATS_DIR)/2.txt
TSTS += $(FORMATS_DIR)/3.txt
TSTS += $(FORMATS_DIR)/4.txt
tests_init: $(OBJS_TESTS)
	@$(CC) $(CFLAGS) $(patsubst %,obj/%,$(OBJS_TESTS)) -o $(TNAME) -lm -no-pie
	@$(foreach file,$(TSTS),./$(TNAME) --silent < $(file);)

clean:
	@rm -rf $(OBJ_DIR) $(PNAME) $(TNAME)