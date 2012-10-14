
;
; Display functions
;
[section .text]
global display_int
global display_string
global display_return

; Display 32bit integer
display_int:
	push edi
	mov eax, [esp+8]

	shr eax, 24
	call _display_AL
	
	mov eax, [esp+8]
	shr eax, 16
	call _display_AL
	
	mov eax, [esp+8]
	shr eax, 8
	call _display_AL
	
	mov eax, [esp+8]
	call _display_AL

	mov ah, 07h
	mov al, 'h'
	mov edi, [dwDispPos]
	mov [gs:edi], ax
	add edi, 2
	mov [dwDispPos], edi
	pop edi
	
	ret

; Display string
display_string:
	push ebp
	mov ebp, esp
	push ebx
	push esi
	push edi

	mov esi, [ebp+8]		; Points to string
	mov edi, [dwDispPos]
	cld
.loopChar:
	lodsb
	test al, al
	jz .endDisplay
	cmp al, 0Ah				; New line?
	jnz .display
	mov eax, edi
	mov bl, 160				; 160 bytes per line
	div bl					; Get the current line
	and eax, 0FFh
	inc eax					; The beginning of next line
	mul bl
	mov edi, eax
	jmp .loopChar
.display:
	mov ah, 0Ch
	mov [gs:edi], ax
	add edi, 2
	jmp .loopChar
.endDisplay:
	mov [dwDispPos], edi
	pop edi
	pop esi
	pop ebx
	mov esp, ebp
	pop ebp
	ret

; Display new line
display_return:
	mov eax, [dwDispPos]
	mov bl, 160
	div bl
	and eax, 0FFh
	inc eax
	mul bl
	mov [dwDispPos], eax
	ret

; Internal function, display number in AL
_display_AL:
	push ecx
	push edx
	push edi
	
	mov edi, [dwDispPos]

	mov ah, 0Ch				; 0000b: black background, 1111b: light red foreground
	mov dl, al
	shr al, 4
	mov ecx, 2
.begin:
	and al, 1111b
	cmp al, 9
	ja .valueBig
	add al, '0'
	jmp .valueSmall
.valueBig:							; A~F
	sub al, 0ah
	add al, 'A'
.valueSmall:
	mov [gs:edi], ax
	add edi, 2

	mov al, dl
	loop .begin
	mov [dwDispPos], edi

	pop edi
	pop edx
	pop ecx
	ret

[section .data]
dwDispPos	dd	0
