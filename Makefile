CC=gcc
LD=ld
OBJCOPY=objcopy

CFLAGS=-c -m32
LD_FLAGS=-Ttext=0x00 -m elf_i386 -s

boot.img: boot/bootsect.bin boot/setup.bin boot/head.bin
	@dd if=/dev/zero of=boot.img bs=512 count=2880
	@dd if=boot/bootsect.bin of=boot.img bs=512 count=1
	@dd if=boot/setup.bin of=boot.img seek=1 bs=512 count=4
	@dd if=boot/head.bin of=boot.img seek=5 bs=512 count=2875

boot/bootsect.bin: boot/bootsect.s
	$(CC) $(CFLAGS) boot/bootsect.s -o boot/bootsect.o
	$(LD) boot/bootsect.o -o boot/bootsect.bin $(LD_FLAGS)

boot/setup.bin: boot/setup.s
	$(CC) $(CFLAGS) boot/setup.s -o boot/setup.o
	$(LD) boot/setup.o -o boot/setup.bin $(LD_FLAGS)

boot/head.bin: boot/head.s
	$(CC) $(CFLAGS) boot/head.s -o boot/head.o
	$(LD) boot/head.o -o boot/head.bin $(LD_FLAGS)
	
clean: 
	@rm -f boot/*.o boot/*.bin

distclean: clean
	@rm -f boot.img
