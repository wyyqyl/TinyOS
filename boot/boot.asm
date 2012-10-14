

SYSSIZE		equ	3000h
BOOTSEG		equ	07c0h
INITSEG		equ	9000h
SETUPSEG	equ	9020h
SYSSEG		equ	1000h
ENDSEG		equ	SYSSEG + SYSSIZE
SETUPLEN	equ	4

[BITS 16]
start:
	mov ax, BOOTSEG
	mov ds, ax
	mov ax, INITSEG
	mov es, ax
	mov cx , 100h
	xor si, si
	xor di, di
	rep movsw
	jmp INITSEG:go
go:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0FF00h

; Clear screen
	mov ax, 0600h
	mov bx, 0700h
	mov cx, 0000h
	mov dx, 184fh
	int 10h

; Resest current cursor
	mov ah, 02h
	xor bh, bh		; page 0
	mov dx, 0		; dh(Y), dl(X)
	int 10h

; load the setup into address: INITSEG + 200h
load_setup:
	mov dx, 0000h	; drive 0, head 0
	mov cx, 0002h	; sector 2, track 0
	mov bx, 0200h	; buffer address = INITSEG + 200h
	mov ax, 0200h + SETUPLEN	; service 2, # of sectors
	int 13h
	jnc ok_load_setup
	mov dx, 0000h
	mov ax, 0000h	; reset the disk
	int 13h
	jmp load_setup


ok_load_setup:
; Get disk driver parameter, specifically nr of sectors/tracks
	mov dl, 0
	mov ax, 0800h
	int 13h			; It will modify ES
	mov ch, 0
	mov [sectors], cx
	mov ax, INITSEG
	mov es, ax		; Change back
	
; print some message
	;mov ah, 03h		; read cursor position
	;xor bh, bh
	;int 10h

	;mov cx, szSystemLen
	;mov bx, 0007h	; page 0, attribute 7 (normal)
	;mov bp, szSystem
	;mov ax, 1301h	; write string, move cursor
	;int 10h

; Time to load the system module...
	mov ax, SYSSEG
	mov es, ax
	call read_it
	call kill_motor
	
	jmp SETUPSEG:0

; This routine loads the system at address at 0x10000
sread:		dw	1 + SETUPLEN	; sectors read of current track
head:		dw	0				; current head
track:		dw	0				; current track

read_it:
	mov ax, es
	test ax, 0FFFh
	jne $						; es must be at 64KB boundary
	xor bx, bx					; bx is the starting address within the segment
rp_read:
	mov ax, es
	cmp ax, ENDSEG				; have we loaded all yet?
	jb ok1_read
	ret
ok1_read:
	mov ax, [sectors]
	sub ax, [sread]
	mov cx, ax
	shl cx, 9
	add cx, bx
	jnc ok2_read
	je ok2_read
	xor ax, ax
	sub ax, bx
	shr ax, 9
ok2_read:
	call read_track
	mov cx, ax
	add ax, [sread]
	cmp ax, [sectors]
	jne ok3_read
	mov ax, 1
	sub ax, [head]
	jne ok4_read
	inc word [track]
ok4_read:
	mov [head], ax
	xor ax, ax
ok3_read:
	mov [sread], ax
	shl cx, 9
	add bx, cx
	jnc rp_read
	mov ax, es
	add ax, 1000h
	mov es, ax
	xor bx, bx
	jmp rp_read

read_track:
	push ax
	push bx
	push cx
	push dx
	mov dx, [track]
	mov cx, [sread]
	inc cx
	mov ch, dl
	mov dx, [head]
	mov dh, dl
	mov dl, 0
	and dx, 0100h
	mov ah, 2
	int 13h
	jc bad_rt
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
bad_rt:
	mov ax, 0
	mov dx, 0
	int 13h
	pop dx
	pop cx
	pop bx
	pop ax
	jmp read_track
	
kill_motor:
	push dx
	mov dx, 03f2h
	mov al, 0
	out dx, al
	pop dx
	ret
	
sectors:	dw	0			; nr of sectors per track
;szSystem:	db	"Loading system...", 0Ah, 0
;szSystemLen	equ	$ - szSystem

times	510-($-$$) db 0
	dw	0aa55h
