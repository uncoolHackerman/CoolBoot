# makefile 05/12/2022
# Written by Gabriel Jickells

ASM=nasm
EMULATOR=qemu-system-i386
CC32=/usr/local/i686-elf-gcc/bin/i686-elf-gcc
LD32=/usr/local/i686-elf-gcc/bin/i686-elf-gcc

CFLAGS32=-c -O2 -ffreestanding -nostdlib
LDFLAGS32=-nostdlib
CLIBS32=-lgcc

SRCDIR=src
BINDIR=bin

# end the branch string with an underscore unless it is empty
VERSION=0.0.1
BRANCH=
PLATFORM=x86
DISK=COOLBOOT_v$(VERSION)_$(BRANCH)$(PLATFORM).img

default: always bootloader
	dd if=/dev/zero of=$(BINDIR)/$(DISK) bs=512 count=2880
	dd if=$(BINDIR)/boot.bin of=$(BINDIR)/$(DISK) conv=notrunc
	mcopy -i $(BINDIR)/$(DISK) $(BINDIR)/stage2.bin "::/stage2.bin"
	mcopy -i $(BINDIR)/$(DISK) $(SRCDIR)/stage2/coolboot.sys "::/coolboot.sys"
	rm $(BINDIR)/*.bin
	rm $(BINDIR)/*.o

bootloader:
	$(ASM) -f bin -o $(BINDIR)/boot.bin $(SRCDIR)/boot.asm
	$(ASM) -f elf -o $(BINDIR)/stage2.o $(SRCDIR)/stage2/stage2.asm
	$(CC32) $(CFLAGS32) $(SRCDIR)/stage2/stage2.c -o $(BINDIR)/stage2a.o
	$(LD32) $(LDFLAGS32) -T linker.ld -Wl,-Map=$(BINDIR)/stage2.map $(BINDIR)/stage2.o $(BINDIR)/stage2a.o -o $(BINDIR)/stage2.bin $(CLIBS32)

always:
	mkdir --parents $(BINDIR)
	touch $(BINDIR)/a.a
	rm $(BINDIR)/*.*

run:
	$(EMULATOR) -fda $(BINDIR)/$(DISK)