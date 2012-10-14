
INITSEG		equ	9000h
SETUPSEG	equ	9020h

[BITS 16]
start:
; Read current cursor
	;mov ax, INITSEG
	;mov ds, ax
	;mov ah, 03h
	;xor bh, bh
	;int 10h
	
	;mov cx, dx
	;movzx eax, ch		; dh=Y
	;mov ebx, 80
	;mul ebx
	;movzx ebx, cl
	;add eax, ebx		; dl=X
	;mov ebx, 2
	;mul ebx
	
	;mov [0], eax		; Save it in INITSEG:0

; Get memory size
	mov ah, 88h
	int 15h
	mov [4], ax

; Get video-card data
	mov ah, 0Fh
	int 10h
	mov [6], bx			; bh = display page
	mov [8], ax			; al = video mode, ah = window width
	
; Check for EGA/VGA and some config parameters
	mov ah, 12h
	mov bl, 10h
	int 10h
	mov [10], ax
	mov [12], bx
	mov [14], cx
	
; Get hd0 data
	mov ax, 0
	mov ds, ax
	lds si, [4*41h]
	mov ax, INITSEG
	mov es, ax
	mov di, 10h
	mov cx, 10h
	rep movsb
	
; Check if there is a hd1
	mov ax, 1500h
	mov dl, 81h
	int 13h
	jc no_disk1
	cmp ah, 3
	jnz no_disk1
; Get hd1 data
	mov ax, 0
	mov ds, ax
	lds si, [4*46h]
	mov ax, INITSEG
	mov es, ax
	mov di, 20h
	mov cx, 10h
	rep movsb
no_disk1:
	
; Check memory
	mov ax, INITSEG
	mov ds, ax
	mov ebx, 0
	mov di, 30h			; 0x90030	memory map 0x100 bytes
	mov dword [0d0h], 0	; 0x900d0	segment 4 bytes
	mov dword [0d4h], 0	; 0x900d4	total memory 4 bytes
LoopChkMem:
	mov eax, 0e820h
	mov ecx, 20
	mov edx, 534d4150h	;'SMAP'
	int 15h
	jc FailChkMem
	cmp dword [di+10h], 1
	jne NotARM
	mov eax, dword [di+8]	; LengthLow
	add eax, dword [0d4h]
	mov dword [0d4h], eax
NotARM:
	inc dword [0d0h]	; 0x900d0
	add di, 20
	cmp ebx, 0
	jnz LoopChkMem
	jmp SucceedChkMem
FailChkMem:
	mov dword [0d0h],0
SucceedChkMem:

; Do some preparations before going into protected mode
	cli
; first we move the system to its rightful place
	mov ax, 0
	cld
do_move:
	mov es, ax		; destination
	add ax, 1000h
	cmp ax, INITSEG
	jz end_move
	mov ds, ax		; source
	xor di, di
	xor si, si
	mov cx, 8000h
	rep movsw
	jmp do_move
	
end_move:
	mov ax, SETUPSEG
	mov ds, ax
	
	lidt [idt_48]
	lgdt [gdt_48]
	
; Enable A20 address line
	in al, 92h
	or al, 10h
	out 92h, al

; Reprogram 8259's interrupt table
	mov	al, 11h				; initialization sequence
	out	20h, al				; send it to 8259A-1
	dw	00EBh, 00EBh		; jmp $+2, jmp $+2
	
	out	0A0h, al			; and to 8259A-2
	dw	00EBh, 00EBh
	
	mov	al, 20h				; start of hardware int's (0x20)
	out	21h, al
	dw	00EBh, 00EBh
	
	mov	al, 28h			; start of hardware int's 2 (0x28)
	out	0A1h, al
	dw	00EBh, 00EBh
	
	mov	al, 04h				; 8259-1 is master
	out	21h, al
	dw	00EBh, 00EBh
	
	mov	al, 02h				; 8259-2 is slave
	out	0A1h, al
	dw	00EBh, 00EBh
	
	mov	al, 01h				; 8086 mode for both
	out	21h, al
	dw	00EBh, 00EBh
	
	out	0A1h, al
	dw	00EBh, 00EBh
	
	mov	al, 0FFh			; mask off all interrupts for now
	out	21h, al
	dw	00EBh, 00EBh
	
	out	0A1h, al

; Enable protected mode
	mov eax, cr0
	or eax, 1
	mov cr0, eax

; jmp to segment 8, offset 0 (protected mode)
	jmp dword 8:0


gdt:
	dw	0,0,0,0			; dummy

	dw	07FFh			; 8Mb - limit=2047 (2048*4096=8Mb)
	dw	0000h			; base address=0
	dw	9A00h			; code read/exec
	dw	00C0h			; granularity=4096, 386

	dw	07FFh			; 8Mb - limit=2047 (2048*4096=8Mb)
	dw	0000h			; base address=0
	dw	9200h			; data read/write
	dw	00C0h			; granularity=4096, 386

idt_48:
	dw	0				; idt limit=0
	dw	0,0				; idt base=0L

gdt_48:
	dw	800h			; gdt limit=2048, 256 GDT entries
	dw	512+gdt, 9		; gdt base = 0x90200+gdt
