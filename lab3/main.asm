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

	cmp ax, 32768
	jc nMinus
		mov cx, ax
		not cx
		cmp cx, 0
		jz ze
		mov ah, 2
		mov dx, '-'
		int 21h
		ze:
		mov ax, cx
	nMinus:

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
		cmp al, 45
		jz fM1
		
		push cx
		call check
		cmp cx,	228
		jz exit
		pop cx
		
		
		cmp cx, 32768
		jc notMin
			not cx
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
			cmp ax, 32768
			jc noBigM
				jmp errbig
			noBigM:
			mov cx, ax
			not cx
			jmp min	
			fM1:
				jmp fM
		notMin:
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
			cmp ax, 32768
			jc noBig
				jmp errbig
			noBig:	
		mov cx, ax
		min:
	
		jmp fEnter
		
	fBS:
		mov ah, 2
		mov dl, ' '
		int 21h
		cmp cx, 32768
		jc fBSM
			not cx
			mov ax, cx
			cmp ax, 0
			jz trZ
				xor dx, dx 
				mov bx, 10
				div bx
				not ax
				mov cx, ax
				call delChar
				jmp fEnter
			trZ:
		fBSM:
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
	fM:
		cmp cx, 0
		jz f2
			push cx
			jmp exit
		f2:
		not cx
		jmp fEnter
	fNE:
	cmp cx, 0
	jz fenter
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
		pop cx
		call delChar
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
	xor cx, cx
	cmp ax, 32768
	jc fNoMinSign1
		not ax
		add cx, 1
	fNoMinSign1:
	
	cmp bx, 32768
	jc fNoMinSign2
		not bx
		add cx, 2
	fNoMinSign2:

	div bx
	
	cmp cx, 1
	jnz noMinusPlus
		add ax, 1
		not ax
		mov cx, bx
		sub cx, dx
		mov dx, cx
	noMinusPlus:

	cmp cx, 2
	jnz noPlusMinus
		not ax
	noPlusMinus:

	cmp cx, 3
	jnz noMinusMinus
		add ax, 1
		mov cx, bx
		sub cx, dx
		mov dx, cx
	noMinusMinus:

	mov bx, dx
	xor cx, cx

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
		mov ax, 4c00h
		int 21h

end main