
; ISR.asm contains the low level code most hardware
; faults, page_exception is handled by mm.


[section .text]
extern display_string, delay, k_reenter
extern do_divide_error, do_debug, do_nmi, do_int3, do_overflow, do_bounds
extern do_invalid_op, dodouble_fault, do_coprocessor_segment_overrun
extern do_invalid_TSS, do_segment_not_present, do_stack_segment
extern do_general_protection, do_reserved

global divide_error, debug, nmi, int3, overflow, bounds
global invalid_op, double_fault, coprocessor_segment_overrun
global invalid_TSS, segment_not_present, stack_segment
global general_protection, irq13, reserved, timer_interrupt

divide_error:
	push do_divide_error
no_error_code:
	xchg eax, [esp]
	push ebx
	push ecx
	push edx
	push edi
	push esi
	push ebp
	push ds
	push es
	push fs
	push 0				; error code
	lea edx, [esp+44]
	push edx
	mov edx, 10h
	mov ds, dx
	mov es, dx
	mov fs, dx
	call eax
	add esp, 8
	pop fs
	pop es
	pop ds
	pop ebp
	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	iretd

debug:
	push do_int3
	jmp no_error_code

nmi:
	push do_nmi
	jmp no_error_code
	
int3:
	push do_int3
	jmp no_error_code
	
overflow:
	push do_overflow
	jmp no_error_code
	
bounds:
	push do_bounds
	jmp no_error_code
	
invalid_op:
	push do_invalid_op
	jmp no_error_code
	
coprocessor_segment_overrun:
	push do_coprocessor_segment_overrun
	jmp no_error_code
	
reserved:
	push do_reserved
	jmp no_error_code

timer_interrupt:
	;xchg bx, bx
	pushad
	push ds
	push es
	push fs
	
	mov ax, ss
	mov ds, ax
	mov es, ax
	mov fs, ax

	; mov al, [gs:0]
	; cmp al, 7fh
	; jnz continue
	; mov byte [gs:0], 20h
; continue:
	; inc byte [gs:0]
	
	mov al, 20h			; reenable 8259A master
	out 20h, al

	inc dword [k_reenter]
	cmp dword [k_reenter], 0
	jnz .re_enter		; Ignore further interrupts
	
	; CPU will automatically disable interrupt
	; when in isr, enable it to receive
	; further interrupt
	sti
	
	push szTimerInterrupt
	call display_string
	add esp, 4
	
	cli
	
.re_enter:
	dec dword [k_reenter]
	pop fs
	pop es
	pop ds
	popad
	iretd

; irq13:
	; push eax
	; xor al, al
	; out 20h, al
	; nop
	; nop
	; out 0A0h, al
	; pop eax
	; jmp coprocessor_error
	
double_fault:
	push double_fault
error_code:
	xchg eax, [esp+4]	; error code <-> eax
	xchg ebx, [esp]		; &function <-> ebx
	push ecx
	push edx
	push edi
	push esi
	push ebp
	push ds
	push es
	push fs
	push eax			; error code
	lea eax, [esp+44]	; offset
	push eax
	mov eax, 10h
	mov ds, ax
	mov es, ax
	mov fs, ax
	call ebx
	add esp, 8
	pop fs
	pop es
	pop ds
	pop ebp
	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	iretd
	
invalid_TSS:
	push do_invalid_TSS
	jmp error_code
	
segment_not_present:
	push do_segment_not_present
	jmp error_code
	
stack_segment:
	push do_stack_segment
	jmp error_code
	
general_protection:
	push do_general_protection
	jmp error_code

[section .rdata]
szTimerInterrupt:	db	"0", 0