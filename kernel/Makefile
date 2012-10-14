#############################
# makefile for TinyOS kernel
#############################

INCLUDE		= ../include
LDFLAGS		= -m elf_i386 -r

CFILES		= $(wildcard *.c)
ASMFILES	= $(wildcard *.asm)
OBJS		= $(CFILES:%.c=%.o) $(ASMFILES:%.asm=%.o)

%.o: %.asm
	$(ASM) $(ASMFLAGS) -I$(INCLUDE) $< -o $@
%.o: %.c
	$(CC) $(CFLAGS) -I$(INCLUDE) $< -o $@

kernel.o: $(OBJS)
	$(LD) $(LDFLAGS) -o kernel.o $(OBJS)
	sync

clean:
	rm -f *.o *.a $(DEPFILE)

$(DEPFILE): $(CFILES)
	$(CC) $(DFLAGS) -I$(INCLUDE) $(CFILES) > $@
	
-include $(DEPFILE)
