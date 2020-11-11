.model small
.stack 100h
.data
	arrin db 100 dup(0)
	arrout dw 100 dup(0)
	n dw 0
.code
.386
read_char proc C near
uses ax
    mov ah, 08h
    int 21h
    mov cl, al
    ret
endp

print_char proc C near
uses ax, dx
    mov ah, 02h
    mov dl, cl
    int 21h
    ret
endp


read_byte proc C near
arg numberb:word
uses ax, bx, cx
	mov ax, 0
	mov cx, 0
	FBSpace:
	call read_char C
	cmp cl, 32
	je FBSpace
	cmp cl, 13
	je FBSpace
	cmp cl, 10
	je FBSpace

	FRB:
		mov bl, 10
		mul bl
		add ax, cx
		sub ax, '0'
		call read_char C
		cmp cl, 32
		je FRBE
		cmp cl, 13
		je FRBE
		cmp cl, 10
		je FRBE
		jmp FRB

	FRBE:
	mov bx, offset numberb
	mov [bx], al
	ret	
endp

read_arr proc C near
arg num:byte, arr:word
	uses ax, bx, cx, dx
	mov cx, 0
	mov cl, byte ptr[num]
	mov bx, offset arr
	ForRead:
		call read_byte C, bx
		inc bx
	loop ForRead
	ret
endp

print_short proc C near
arg Nshort:word
uses ax, bx, cx, dx, si
	mov cx, 0
	mov si, 0
	mov al, byte ptr[Nshort]
	mov ah, byte ptr[Nshort + 1]
	dec ax
	mov bx, 10
	divShort:
		mov dx, 0
		div bx
		mov cl, dl
		add cl, '0'
		push cx
		inc si
		cmp ax, 0
		je EDivShort
	jmp divShort
	EDivShort:

	mov cx, si
	osh:
		pop dx
		push cx
		mov cx, dx
		call print_char C
		pop cx
	loop osh
	ret
	
endp

floid proc C near
arg line:word, position:word
uses ax, bx, cx, dx, di, si
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov di, 0
	mov si, 0
	mov di, line
	mov si, position
	mov cx, [n]
	forFloid:
		mov ax, si
		mov dx, 0
		push cx
		mov cx, [n]
		mul cx
		pop cx
		mov bx, ax
		add bx, cx
		dec bx
		mov al, arrin[bx]
		mov dx, ax
							jmp cnt
								forFloid2:
								jmp forfloid
							cnt:
		mov bx, di
		add bx, di
		add bx, si
		add bx, si
		mov al, byte ptr arrout[bx]
		inc bx
		mov ah, byte ptr arrout[bx]
		add dx, ax
		mov bx, di
		add bx, di
		add bx, cx
		add bx, cx
		sub bx, 2
		mov al, byte ptr arrout[bx]
		inc bx
		mov ah, byte ptr arrout[bx]
		cmp dx, ax
		
		jnc GoNext
			zerostep:
			dec cx
			dec bx
			add bx, offset arrout
			mov [bx], dl
			inc bx
			mov [bx], dh
			call floid C, di, cx
			inc cx
			jmp toloopF
		GoNext:
		cmp ax, 0
		je zerostep
		toloopF:
	loop forFloid2
	ret
endp

outarrxx proc C
uses ax, bx, cx, dx, si, di
	mov ax, [n]
	mov cx, ax
	mul cl
	mov cx, ax
	mov di, 0
	OutArr:
		mov bl, byte ptr arrout[di]
		inc di
		mov bh, byte ptr arrout[di]
		call print_short C, bx
		mov bx, [n]
		add bx, [n]
		mov ax, di
		inc ax
		mov dx, 0
		div bx
		inc di
		cmp dx, 0
		je outEnter
		push cx
		mov cl, 32
		call print_char C
		pop cx
		jmp Toloop	
		outEnter:
		push cx
		mov cl, 10
		call print_char C
		mov cl, 13
		call print_char C
		pop cx
		Toloop:

	loop OutArr
ret
endp

main:
	mov ax, @data
	mov ds, ax
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov di, 0
	mov si, 0
	call read_byte C, offset n
	mov bx, offset n
	mov ax, [n]
	mov cx, ax
	mul cl
	call read_arr C, ax, offset arrin
	mov cx, [n]
	mov di, 0
	Diahonal:
		inc arrout[di]
		add di, 2
		add di, [n]
		add di, [n]
	loop Diahonal
	
	mov cx, [n]
	mov di, 0
	mov si, 0
	ForObh:
		call floid C, di, si
		inc si
		add di, [n]
	loop ForObh
	



	call outarrxx C
	call read_char C
	mov ax, 4c00h
	int 21h

end main