CC=gcc
LD=ld
OBJCOPY=objcopy

INCLUDE=include

CFLAGS=-c -m32 -nostdinc -I$(INCLUDE) -fno-builtin -fno-stack-protector
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
	$(CC) $(CFLAGS) kernel/blk_drv/ll_rw_blk.c -o kernel/blk_drv/ll_rw_blk.o
	$(CC) $(CFLAGS) kernel/blk_drv/hd.c -o kernel/blk_drv/hd.o
	$(CC) $(CFLAGS) kernel/blk_drv/floppy.c -o kernel/blk_drv/floppy.o
	$(CC) $(CFLAGS) kernel/blk_drv/ramdisk.c -o kernel/blk_drv/ramdisk.o
	$(CC) $(CFLAGS) kernel/chr_drv/console.c -o kernel/chr_drv/console.o
	$(CC) $(CFLAGS) kernel/chr_drv/keyboard.S -o kernel/chr_drv/keyboard.o
	$(CC) $(CFLAGS) kernel/chr_drv/rs_io.s -o kernel/chr_drv/rs_io.o
	$(CC) $(CFLAGS) kernel/chr_drv/serial.c -o kernel/chr_drv/serial.o
	$(CC) $(CFLAGS) kernel/chr_drv/tty_io.c -o kernel/chr_drv/tty_io.o
	$(CC) $(CFLAGS) kernel/sched.c -o kernel/sched.o
	$(CC) $(CFLAGS) kernel/system_call.s -o kernel/system_call.o
	$(CC) $(CFLAGS) kernel/vsprintf.c -o kernel/vsprintf.o
	$(CC) $(CFLAGS) kernel/printk.c -o kernel/printk.o
	$(CC) $(CFLAGS) kernel/signal.c -o kernel/signal.o
	$(CC) $(CFLAGS) kernel/sys.c -o kernel/sys.o
	$(CC) $(CFLAGS) kernel/panic.c -o kernel/panic.o
	$(CC) $(CFLAGS) lib/ctypes.c -o lib/ctypes.o
	$(CC) $(CFLAGS) lib/string.c -o lib/string.o
	$(CC) $(CFLAGS) math/math_emulate.c -o math/math_emulate.o
	$(CC) $(CFLAGS) fs/buffer.c -o fs/buffer.o
	$(LD) $(LD_FLAGS) boot/head.o init/main.o mm/memory.o kernel/traps.o kernel/system_call.o\
		kernel/asm.o kernel/blk_drv/ll_rw_blk.o kernel/mktime.o kernel/sched.o\
		kernel/chr_drv/console.o kernel/chr_drv/keyboard.o kernel/chr_drv/rs_io.o\
		kernel/chr_drv/serial.o kernel/chr_drv/tty_io.o  kernel/printk.o kernel/signal.o\
		kernel/vsprintf.o lib/ctypes.o lib/string.o math/math_emulate.o kernel/sys.o\
	  	fs/buffer.o kernel/blk_drv/hd.o kernel/blk_drv/floppy.o kernel/blk_drv/ramdisk.o \
		kernel/panic.o -o system.elf 
	$(OBJCOPY) $(TRIM_FLAGS) system.elf $@
	
clean: 
	@find . -regextype "posix-egrep" -regex ".*\.(o|bin|elf)$\" -exec rm '{}' \;

distclean: clean
	@rm -f boot.img
