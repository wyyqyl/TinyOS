##########################
# makefile for TinyOS
##########################

export ASM	= nasm
export CC	= gcc
export LD	= ld
OBJCOPY		= objcopy

export DEPFILE	= depends.dep
export ASMFLAGS	= -f elf
export CFLAGS	= -fno-builtin -fno-stack-protector -c -m32 -nostdinc -nostdlib
export DFLAGS	= -M -nostdinc

LDFLAGS		= -s -Ttext=0x00 -m elf_i386
TRIM_FLAGS	= -R .pdr -R .comment -R.note -S -O binary

BOOT	= boot/boot
SETUP	= boot/setup
MODULES	= kernel/kernel.o lib/lib.a
SYSTEM	= system
IMAGE	= a.img
SUBDIRS	= $(dir $(MODULES))

%: %.asm
	$(ASM) $< -o $@

.PHONY: all $(DEPFILE) $(MODULES) clean

all: $(DEPFILE) $(BOOT) $(SETUP) $(SYSTEM)
	@dd if=/dev/zero of=$(IMAGE) bs=512 count=2880 conv=notrunc 2>/dev/null
	@dd if=$(BOOT) of=$(IMAGE) bs=512 count=1 conv=notrunc 2>/dev/null
	@dd if=$(SETUP) of=$(IMAGE) bs=512 count=4 seek=1 conv=notrunc 2>/dev/null
	@dd if=$(SYSTEM) of=$(IMAGE) bs=512 count=2875 seek=5 conv=notrunc 2>/dev/null
	sync

clean:
	@rm -f $(BOOT) $(SETUP) boot/*.o \
		$(IMAGE) $(SYSTEM) $(SYSTEM).o
	@for dir in $(SUBDIRS); do \
		make clean -s -C $$dir; \
	done

$(SYSTEM): boot/head.o $(MODULES)
	$(LD) $(LDFLAGS) -o $(SYSTEM).o $^
	$(OBJCOPY) $(TRIM_FLAGS) $(SYSTEM).o $@

$(BOOT): $(BOOT).asm

$(SETUP): $(SETUP).asm

boot/head.o: boot/head.asm
	$(ASM) $(ASMFLAGS) $< -o $*.o

$(MODULES):
	@make -C $(dir $@)
	
$(DEPFILE):
	@for dir in $(SUBDIRS); do \
		make $(DEPFILE) -s -C $$dir; \
	done

