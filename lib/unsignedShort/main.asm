.model small
.stack 100h
.code
.386


delCharUS proc
	push ax
	push dx
	xor ax, ax
	xor dx, dx
	mov ah, 2
	mov dl, 8
	int 21h
	mov dl, ' '
	int 21h
	mov dl, 8
	int 21h
	pop dx
	pop ax
	ret
delCharUS endp



outUShort proc 
	pusha
	mov bx, 10
	mov cx, 0
	WUShort:
		mov dx, 0
		div bx
		add dx, '0'
		push dx
		inc cx
	test ax, ax 
	jnz WUShort
	
	LUS:
		mov ah, 02h     
        pop dx      
        int 21h
    loop LUS    
	
	mov ah, 2
	mov dx, 0dh      
	int 21h
	mov dx, 0ah      
	int 21h
	popa
	ret
outUShort endp

inUShort proc
	push bx
	push cx
	push dx
	xor ax, ax
	mov bx, 10
	WIUShort:
		mov ah, 8
		int 21h
		mov ah, 2
		mov dl, al
		int 21h
		cmp al , '0'
		jz RZToUShort
		GBToIUS:
		xor ah, ah
		cmp al, 13
		jz fEntUS
		cmp al, 8
		jz fBSUS
		cmp al, 27
		jz fEscUS		
		push cx
		call check
		cmp cx,	228
		jz exitUS
		pop cx
		
		
		
		sub al, '0'
		xor bx, bx
		mov bx, ax
		mov ax, cx
		mov cx, bx
		mov bx, 10
		mul bx
		add ax, cx
		jc ExBigUS
		cmp dl, 0
		jnz ExBigUS		
		
		mov cx, ax
		cmp cx, 0
		jz fDel
		jmp WIUShort
		fDel:
			mov ah, 02h  
			mov dx, 0dh      
			int 21h
			mov dx, 0ah      
			int 21h
			mov dx, 'W'     
			int 21h
			mov dx, 'I'      
			int 21h
			mov dx, 0dh      
			int 21h
			mov dx, 0ah      
			int 21h
			call delCharUS
			jmp WIUShort
		
	fBSUS:
		mov ah, 2
		mov dl, ' '
		int 21h
		xor dx, dx 
		mov ax, cx
		mov bx, 10
		div bx
		mov cx, ax
		call delCharUS
		jmp WIUShort
	fEscUS:
		push cx
		mov cx, 10
		f1:
			call delCharUS
		loop f1
		pop cx
		xor ax, ax
		xor bx, bx
		xor cx, cx
		xor dx, dx
		jmp WIUShort
	fEntUS:
	cmp cx, 0
	jz WIUShort
	mov ah, 2
	mov dx, 0dh      
	int 21h
	mov dx, 0ah      
	int 21h
	mov ax, cx
	pop dx
	pop cx
	pop bx
	ret
	
	ExBigUS:
		
		call inUShort
		pop dx
		pop cx
		pop bx
		ret
	exitUS:
		call delCharUS
		pop cx
		jmp WIUShort
	RZToUShort:
		mov ah, 2
		mov dx, 0dh      
		int 21h
		mov dx, 0ah      
		int 21h
		cmp cx, 0
		jnz GBToIUS
		pop dx
		pop cx
		pop bx
		mov ax, 0
		ret
inUShort endp

check proc

	cmp al, '0'
	jc erNNUS
	cmp al, '9'
	ja erNNUS
	ret
	erNNUs:
		mov cx, 228
		ret

check endp

main:
	mov ax, @data
	mov ds, ax
	xor cx, cx
	call inushort
	call outUShort
	mov ah, 8
	int 21h
	mov ax, 4c00h
	int 21h
end main
	
