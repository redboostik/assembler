.model small
.stack 100h
.data
	sEnter1 db 0dh, 0ah, "Enter first number", 0dh, 0ah, "$" 
	sEnter2 db 0dh, 0ah, "Enter second number", 0dh, 0ah, "$"
	erBig db 0dh, 0ah, "wrong input (so big number)", 0dh, 0ah, "$"
	erDivZero db 0dh, 0ah, "Divide by Zero", 0dh, 0ah, "$"
	sRes db 0dh, 0ah, "Result: $"
	sMod db , 0dh, 0ah,"Mod: $"
.code
.386


delChar proc
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
delChar endp



outAX proc 

	push ax
	push bx
	push cx
	push dx
	mov bx, 10
	mov cx, 0
	flagdiv:
	mov dx, 0
	
	div bx
	add dx, '0'
	push dx
	
	inc cx
	
	test ax, ax 
	jnz flagdiv
	
	outsymbol:
		mov ah, 02h     
        pop dx      
        int 21h
        loop outsymbol     
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
outAX endp

inAX proc
	push bx
	push cx
	push dx
	mov bx, 10
	fEnter:
	
		mov ah, 8
		int 21h
		mov ah, 2
		mov dl, al
		int 21h
		cmp al , '0'
		jz itIsZero
		goBack:
		xor ah, ah
		cmp al, 13
		jz fNE
		cmp al, 8
		jz fBS
		cmp al, 27
		jz fE
		
		
		push cx
		call check
		cmp cx,	228
		jz exit
		pop cx
		
		
		
		sub al, '0'
		xor bx, bx
		mov bx, ax
		mov ax, cx
		mov cx, bx
		mov bx, 10
		mul bx
		add ax, cx
		jc errBig
		cmp dl, 0
		jnz errBig		
		
		mov cx, ax
		cmp cx, 0
		jz fDel
		jmp fEnter
		fDel:
			call delChar
			jmp fEnter
		
	fBS:
		mov ah, 2
		mov dl, ' '
		int 21h
		xor dx, dx 
		mov ax, cx
		mov bx, 10
		div bx
		mov cx, ax
		call delChar
		jmp fEnter
	fE:
		push cx
		mov cx, 10
		f1:
			call delChar
		loop f1
		pop cx
		xor ax, ax
		xor bx, bx
		xor cx, cx
		xor dx, dx
		jmp fEnter
	fNE:
	cmp cx, 0
	jz fEnter
	mov ax, cx
	pop dx
	pop cx
	pop bx
	ret
	
	errBig:
		mov ah, 09h
		lea dx, erBig
		int 21h
		pop dx
		pop cx
		pop bx
		mov cx, 228
		ret
	exit:
		call delChar
		pop cx
		jmp fEnter
	itIsZero:
		cmp cx, 0
		jnz goBack
		pop dx
		pop cx
		pop bx
		mov ax, 0
		ret
inAX endp

check proc

	cmp al, '0'
	jc erNN
	cmp al, '9'
	ja erNN
	ret
	erNN:
		mov cx, 228
		ret

check endp

main:
	mov ax, @data
	mov ds, ax
	
	
	trAg1:
		mov ah, 09h
		lea dx, sEnter1
		int 21h
		
		mov dx, 0
		mov cx, 0
		call inAX
		cmp cx, 228
		jz trAg1
	
	
		mov bx, ax
		
	trAg2:
		mov ah, 09h
		lea dx, sEnter2
		int 21h
		
		mov dx, 0
		mov cx, 0
		call inAX
		cmp cx, 228
		jz trAg2
		
	xor dx, dx
	mov cx, ax
	mov ax, bx
	mov bx, cx
	
	cmp bx, 0
	jz DZ
	mov cx, ax
	mov ah, 09h
	lea dx, sRes
	int 21h
	xor dx, dx
	mov ax, cx
	div bx
	mov bx, dx

	call outAX
	mov ah, 09h
	lea dx, sMod
	int 21h
	mov ax, bx
	call outAX
	mov ah, 8
	int 21h
	mov ax, 4c00h
	int 21h

	DZ:
		mov ah, 09h
		lea dx, erDivZero
		int 21h
		mov ah, 8
		int 21h
		mov ax, 4c00h
		int 21h

end main