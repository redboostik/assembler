.model small
.stack 100h
.data
a dw 65000
b dw 2
c dw 10000
d dw 0
.code
main:
	mov ax, @data
	mov ds, ax

	mov ax, a
	add ax, c
	jc jump1
	mov bx,	b
	xor bx, d 
	
	cmp ax, bx
	jz firstIf
	jump1:
	
	mov ax, a
	add ax, c
	jc jump2
	mov bx,	b
	and bx, d 
	
	cmp ax, bx
	
	jz secondIf
	jump2:
		mov ax, a
		add ax, d
		
		mov bx, b
		or bx, c
		
		and ax, bx
	jmp flagEnd
	
	secondIf:
		mov ax, a
		xor ax, b
		
		mov bx, c
		xor bx, d
		
		add ax, bx
		
		jmp flagEnd
	
	
	firstIf:
		mov ax, a
		or ax, b
		or ax, c
		add ax, d

	
	flagEnd:

	mov ax, 4c00h
	int 21h
	
end main