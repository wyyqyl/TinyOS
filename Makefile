CC=gcc
LD=ld
OBJCOPY=objcopy

INCLUDE=include

CFLAGS=-c -m32 -I$(INCLUDE)
LD_FLAGS=-Ttext=0x00 -m elf_i386 -s
TRIM_FLAGS=-R .pdr -R .comment -R.note -S -O binary

boot.img: boot/bootsect.bin boot/setup.bin system.bin
	@dd if=/dev/zero of=boot.img bs=512 count=2880
	@dd if=boot/bootsect.bin of=boot.img bs=512 count=1
	@dd if=boot/setup.bin of=boot.img seek=1 bs=512 count=4
	@dd if=system.bin of=boot.img seek=5 bs=512 count=2875

boot/bootsect.bin: boot/bootsect.s
	$(CC) $(CFLAGS) boot/bootsect.s -o boot/bootsect.o
	$(LD) boot/bootsect.o -o boot/bootsect.elf $(LD_FLAGS)
	$(OBJCOPY) $(TRIM_FLAGS) boot/bootsect.elf $@

boot/setup.bin: boot/setup.s
	$(CC) $(CFLAGS) boot/setup.s -o boot/setup.o
	$(LD) boot/setup.o -o boot/setup.elf $(LD_FLAGS)
	$(OBJCOPY) $(TRIM_FLAGS) boot/setup.elf $@

system.bin: boot/head.s init/main.c
	$(CC) $(CFLAGS) boot/head.s -o boot/head.o
	$(CC) $(CFLAGS) init/main.c -o init/main.o
	$(CC) $(CFLAGS) mm/memory.c -o mm/memory.o
	$(CC) $(CFLAGS) kernel/traps.c -o kernel/traps.o
	$(CC) $(CFLAGS) kernel/asm.s -o kernel/asm.o
	$(CC) $(CFLAGS) kernel/mktime.c -o kernel/mktime.o
	$(LD) boot/head.o init/main.o mm/memory.o kernel/traps.o \
		kernel/asm.o kernel/mktime.o -o system.elf $(LD_FLAGS)
	$(OBJCOPY) $(TRIM_FLAGS) system.elf $@
	
clean: 
	@rm -f *.bin *.elf boot/*.o boot/*.bin boot/*.elf init/*.o init/*.o \
		kernel/*.o mm/*.o

distclean: clean
	@rm -f boot.img
