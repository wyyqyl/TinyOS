
[section .text]
extern display_string
extern display_return
extern display_int
extern main
extern stack_start

[BITS 32]
global page_dir, _start, gdt, idt
page_dir:					; page directory will override this range
_start:
	mov eax, 10h
	mov ds, ax
	mov es, ax
	mov fs, ax
	lss esp, [stack_start]

	call setup_idt
	call setup_gdt
	jmp 08h:reloadSeg

reloadSeg:	
	mov eax, 10h
	mov ds, ax
	mov es, ax
	mov fs, ax
	lss esp, [stack_start]

	mov ax, 1Bh
	mov gs, ax

; Check if A20 is enabled
	xor eax, eax
check:
	inc eax
	mov [0], eax
	cmp eax, [10000h]
	je check

; Print welcome message	
	push szWelcome
	call display_string
	add esp, 4

	jmp after_page_tables

setup_idt:
	mov edx, ignore_int
	mov eax, 00080000h
	mov ax, dx
	mov dx, 8E00h
	
	mov edi, idt
	mov ecx, 256
rp_sidt:
	mov [edi], eax
	mov [edi+4], edx
	add edi, 8
	dec ecx
	jne rp_sidt
	lidt [idt_desc]
	ret

setup_gdt:
	lgdt [gdt_desc]
	ret

szWelcome		db	"Welcome to yorath's TinyOS...", 0Ah, 0

times 1000h-($-$$) db 0
pg0: times 1000h db 0		; org 1000h
pg1: times 1000h db 0		; org 2000h
pg2: times 1000h db 0		; org 3000h
pg3: times 1000h db 0		; org 4000h

after_page_tables:
	push error			; return address, coz main will never return
						; if it returns, the system hangs
	push main 
	jmp setup_paging

error:
	jmp error

ignore_int:
	push szIgnoreInt
	call display_string
	add esp, 4
	iretd

setup_paging:
	mov ecx, 5*1024			; 5 pages (1 page_dir + 4 page tables)
	xor eax, eax
	xor edi, edi
	cld
	rep stosd
	mov dword [page_dir+00h], pg0+7	; set present bit,user r/w
	mov dword [page_dir+04h], pg1+7
	mov dword [page_dir+08h], pg2+7
	mov dword [page_dir+0Ch], pg3+7

	mov edi, pg3+4092		; Last entry in last page table
	mov eax, 0FFF007h
	std
fill:
	stosd
	sub eax, 1000h
	jge fill
	xor eax, eax
	mov cr3, eax			; cr3 points to page_dir
	mov eax, cr0
	or eax, 80000000h
	mov cr0, eax			; set PG bit
	ret

szIgnoreInt		db	"Unknown interrupt", 0ah, 0

align 4
idt_desc:	dw	256*8-1
			dd	idt

align 4
gdt_desc:	dw	256*8-1
			dd	gdt

%macro DESCRIPTOR 3				; Base,Limit,Attribute
	dw	%2 & 0ffffh				; offset
	dw	%1 & 0ffffh				; Base address low 16 bit
	db	(%1 >> 16) & 0ffh		; Base address 17～24bit
	dw	((%2 >> 8) & 0f00h) | (%3 & 0f0ffh)
	db	(%1 >> 24) & 0ffh		; Base address high 8 bit
%endmacro

align 8
idt:	times	256	dq	0

gdt:
	Gdt0	DESCRIPTOR 00000000h, 000000h, 00000h	; Null descriptor
	Gdt1	DESCRIPTOR 00000000h, 0fffffh, 0c09Ah	; Ring0 RE code segment
	Gdt2	DESCRIPTOR 00000000h, 0fffffh, 0c092h	; Ring0 RW data segment
	;Gdt3	DESCRIPTOR 00000000h, 0fffffh, 0c0fah	; Ring3 RE code segment
	;Gdt4	DESCRIPTOR 00000000h, 0fffffh, 0c0f2h	; Ring3 RW data segment
	Gdt3	DESCRIPTOR 000B8000h, 00ffffh, 040F2h	; Video memory, can be accessed in Ring3
	;Gdt6	DESCRIPTOR 00720000h, 000068h, 00089h	; Available TSS
	times	252 dq 0
