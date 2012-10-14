#############################
# makefile for TinyOS library
#############################

INCLUDE		= ../include

CFILES		= $(wildcard *.c)
ASMFILES	= $(wildcard *.asm)
OBJS		= $(CFILES:%.c=%.o) $(ASMFILES:%.asm=%.o)

%.o: %.asm
	$(ASM) $(ASMFLAGS) -I$(INCLUDE) $< -o $@
%.o: %.c
	$(CC) $(CFLAGS) -I$(INCLUDE) $< -o $@

lib.a: $(OBJS)
	$(AR) rcs lib.a $(OBJS)
	sync

clean:
	rm -f *.o *.a $(DEPFILE)

$(DEPFILE): $(CFILES)
	$(CC) $(DFLAGS) -I$(INCLUDE) $(CFILES) > $@
	
-include $(DEPFILE)
