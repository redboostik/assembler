.model small
.stack 100h
.286
.386
.data
     old dd (?)
	 symbol dw 20
	 scancoded db "  1234567890-=  qwertyuiop[]  asdfghjkl;    zxcvbnm,./  "
	 scancodeu db "  !@#$%^&*()_+  QWERTYUIOP{}  ASDFGHJKL:    ZXCVBNM<>?  "
	 vowels db "euioa"
	 consonants db "qwrtypsdfghjklzxcvbnm"
	 ctrls db 'C',0Ah,'T',0Bh,'R',0Dh,'L',0Ch,' ',08h
	 shifts db 'S',0Bh,'H',0Ah,'I',0Ah,'F',09h,'T',08h
	 alts db 'A',07h,'L',06h,'T',05h,' ',08h,' ',08h
	 f1s db 'F',0Ah,'1',02h,' ',08h,' ',08h,' ',08h
	 f2s db 'F',0Ah,'2',02h,' ',08h,' ',08h,' ',08h
	 f3s db 'F',0Ah,'3',02h,' ',08h,' ',08h,' ',08h
	 f4s db 'F',0Ah,'4',02h,' ',08h,' ',08h,' ',08h
	 f5s db 'F',0Ah,'5',02h,' ',08h,' ',08h,' ',08h
	 f6s db 'F',0Ah,'6',02h,' ',08h,' ',08h,' ',08h
	 f7s db 'F',0Ah,'7',02h,' ',08h,' ',08h,' ',08h
	 f8s db 'F',0Ah,'8',02h,' ',08h,' ',08h,' ',08h
	 f9s db 'F',0Ah,'9',02h,' ',08h,' ',08h,' ',08h
	 f10s db 'F',0Ah,'1',02h,'0',02h,' ',08h,' ',08h
	 f11s db 'F',0Ah,'1',02h,'1',02h,' ',08h,' ',08h
	 f12s db 'F',0Ah,'1',02h,'2',02h,' ',08h,' ',08h
	 upflag dw (0)
	 ignoreFlag dw (0)  ; 1b is low, 2b is up, 3b is symb, 4b is voowel, 5b is consonant 
	 alphabetmy db "qwertyuiopasdfghjklzxcvbnm", 0Ah, '$'
	 params db "params:", 0Ah, '$'
	 alphabetnew db 26 dup(0)
.code
org 100h
print_char proc C far
uses ax, dx
    mov ah, 02h
    mov dl, cl
    int 21h
    ret
endp

print_short proc C far
arg Nshort:word
uses ax, bx, cx, dx, si
	mov cx, 0
	mov si, 0
	mov al, byte ptr[Nshort]
	mov ah, byte ptr[Nshort + 1]
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

sound proc C near
arg frequency:word
	push ax
	push bx
	push cx
	push dx
	push di
	mov di, word ptr[frequency]
	mov bx, 50
	mov al,0b6H
	out 43H,al
	mov dx,0014H
	mov ax,4f38H
	div di
	out 42H,al
	mov al,ah
	out 42H,al
	in al,61H
	mov ah,al
	or al,3
	out 61H,al
	l1:     mov cx,5801H
	l2:     loop l2
	dec bx
	jnz l1
	mov al,ah
	out 61H,al
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret
sound endp

 change proc far
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	
	cli 
		xor ax,ax
		in al, 60h
		push ax
		mov al, 20h
		out 20h, al
		pop ax

		cmp ax, 1 ; ESC
		je inesc
		jmp escend
			inesc:
			mov dx, word ptr[old]
			mov ds, word ptr[old + 2]
			mov ax,2509h
			int 21h 
			mov ax, 4c00h
			int 21h

		escend:
		cmp ax, 14 ; BackSpace
		je inbs
		jmp bsend
			inbs:
			push ax
			push dx
			mov ah, 2
			mov dl, 8
			int 21h
			mov dl, ' '
			int 21h
			mov dl, 8
			int 21h
			pop dx
			pop ax
			jmp exit1
		bsend:

		cmp ax, 15 ; Tab
		je intab
		jmp tabend
			intab:
			push ax
			push dx
			mov ah, 2
			mov dl, 9
			int 21h
			pop dx
			pop ax
			jmp exit1
		tabend:

		cmp ax, 28; Enter
		je inenter
		jmp enterend
			inenter:
			push ax
			push dx
			mov ah, 2
			mov dl, 10
			int 21h
			pop dx
			pop ax
			jmp exit1
		enterend:

		cmp ax, 29; CTRL
		je inctrl
		jmp ctrlend
			inctrl:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset ctrls
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax , 1500
			call sound C,ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit1
		ctrlend:

		cmp ax, 40; quote
		je inquote
		jmp quoteend
			inquote:
			push ax
			push dx
			mov ax, word ptr [ignoreflag]
			and ax, 100b
			cmp ax, 100b
			je quotedown
			mov dx , word ptr[upflag]
			xor dl, dh
			mov dh, 0
			cmp dx, 1
			je quoteup
				mov ah, 2
				mov dl, 34
				int 21h
			jmp quotedown
			quoteup:
				mov ah, 2
				mov dl, 39
				int 21h
			quotedown:
			pop dx
			pop ax
			jmp exit1
		quoteend:
		
		cmp ax, 41; tilda
		je intilda
		jmp tildaend
			intilda:
			mov ax, word ptr [ignoreflag]
			and ax, 100b
			cmp ax, 100b
			je exit1
			push ax
			push dx
			mov dx , word ptr[upflag]
			xor dl, dh
			mov dh, 0
			cmp dx, 1
			je tildaup
				mov ah, 2
				mov dl, 96
				int 21h
			jmp tildadown
			tildaup:
				mov ah, 2
				mov dl, 126
				int 21h
			tildadown:
			pop dx
			pop ax
			jmp exit1
		tildaend:

		cmp ax, 42; ShiftOn
		je inshift
		jmp shiftend
			inshift:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset shifts
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax , 1000
			call sound C,ax
			mov byte ptr[upflag], 1
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit1
		shiftend:

		jmp across1 
		exit1:
		jmp exit2
		across1:

		cmp ax, 43; backSlash
		je inbslash
		jmp bslashend
			inbslash:
			push ax
			push dx
			mov ax, word ptr [ignoreflag]
			and ax, 100b
			cmp ax, 100b
			je bslashdown
			mov dx , word ptr[upflag]
			xor dl, dh
			mov dh, 0
			cmp dx, 1
			je bslashup
				mov ah, 2
				mov dl, 92
				int 21h
			jmp bslashdown
			bslashup:
				mov ah, 2
				mov dl, 124
				int 21h
			bslashdown:
			pop dx
			pop ax
			jmp exit2
		bslashend:
		
		cmp ax, 56; ALT
		je inalt
		jmp altend
			inalt:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset alts
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax , 1000
			call sound C,ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit2
		altend:

		cmp ax, 58; capsOn
		je incapsOn
		jmp capsOnend
			incapsOn:
			push ax
			push dx
			mov byte ptr[upflag + 1], 1
			pop dx
			pop ax
			jmp exit2
		capsOnend:

		cmp ax, 59; F1
		je inf1
		jmp f1end
			inf1:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f1s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 277
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit2
		f1end:

		cmp ax, 60; F2
		je inf2
		jmp f2end
			inf2:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f2s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 293
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit2
		f2end:

		cmp ax, 61; F3
		je inf3
		jmp f3end
			inf3:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f3s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 311
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit2
		f3end:

		cmp ax, 62; F4
		je inf4
		jmp f4end
			inf4:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f4s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 329
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit2
		f4end:
		
		cmp ax, 63; F5
		je inf5
		jmp f5end
			inf5:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f5s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 349
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit2
		f5end:
		
		jmp across2 
		exit2:
		jmp exit3
		across2:

		cmp ax, 64; F6
		je inf6
		jmp f6end
			inf6:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f6s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 370
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit3
		f6end:
		
		cmp ax, 65; F7
		je inf7
		jmp f7end
			inf7:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f7s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 392
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit3
		f7end:

		cmp ax, 66; F8
		je inf8
		jmp f8end
			inf8:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f8s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 415
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit3
		f8end:

		cmp ax, 67; F9
		je inf9
		jmp f9end
			inf9:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f9s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 440
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit3
		f9end:

		cmp ax, 68; F10
		je inf10
		jmp f10end
			inf10:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f10s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 466
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit3
		f10end:
		
		cmp ax, 87; F11
		je inf11
		jmp f11end
			inf11:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f11s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 493
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit3
		f11end:

		cmp ax, 88; F12
		je inf12
		jmp f12end
			inf12:
			push ax
			push dx
			push bx
			push cx
			push bp
			push @data
			pop  es
   			mov bp,offset f12s
   			mov ax,1302h
    		mov bx,7
    		mov cx,5
    		xor DX,DX
    		int 10h 
			mov ax, 523
			call sound C, ax
			pop bp
			pop cx
			pop bx
			pop dx
			pop ax
			jmp exit3
		f12end:

		jmp across3 
		exit3:
		jmp exit
		across3:

		cmp ax, 186; capsOff
		je incapsOff
		jmp capsOffend
			incapsOff:
			push ax
			push dx

			mov byte ptr[upflag + 1], 0

			pop dx
			pop ax
			jmp exit
		capsOffend:

		cmp ax, 160 ;shiftOff
		je inshiftOff
		jmp shiftOffend
			inshiftOff:
			push ax
			push dx
			mov byte ptr[upflag], 0
			pop dx
			pop ax
			jmp exit
		shiftOffend:

		cmp ax, 60 ;other
		jnc exit
		mov dx , word ptr[upflag]
		xor dl, dh
		mov dh, 0
		mov si, ax
		mov bl, byte ptr scancoded[si]
		mov di, 0
		mov cx, 26
		lo2:
			mov bh, byte ptr alphabetmy[di]
			cmp bh, bl
			je isletter
			inc di
		loop lo2
			mov ax, word ptr [ignoreflag]
			and ax, 100b
			cmp ax, 100b
			je exit
		mov si, ax
		jmp noletter

		isletter:

			mov bh, byte ptr alphabetnew[di]
			push di
			mov cx, 5
			lovowels:
				dec cx
				mov di, cx
				mov bl, byte ptr vowels[di]
				inc cx
				cmp bh, bl
				je isvowel
			loop  lovowels
			jmp novowel
			isvowel:
				pop di
				mov ax, word ptr [ignoreflag]
				and ax, 1000b
				cmp ax, 1000b
				je exit
				jmp overvowel
			novowel:
				pop di
				mov ax, word ptr [ignoreflag]
				and ax, 10000b
				cmp ax, 10000b
				je exit
			overvowel:

			
			mov si, 0
			mov cx, 56
			lo3:
				mov bl, byte ptr scancoded[si]
				cmp bh, bl
				je noletter
				inc si
			loop lo3

		noletter:

		push ax
		push dx
		cmp dx, 1
		je otherup
			mov ax, word ptr [ignoreflag]
			and ax, 1b
			cmp ax, 1b
			je otherdown
			mov dh, 0
			mov dl, scancoded[si]
			mov ah, 2
			int 21h
		jmp otherdown
		otherup:
			mov ax, word ptr [ignoreflag]
			and ax, 10b
			cmp ax, 10b
			je otherdown
			mov dh, 0
			mov dl, scancodeu[si]
			mov ah, 2
			int 21h
		otherdown:
		pop dx
		pop ax

	sti
	exit:
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	iret
 change endp

main:
mov ax, @data
mov ds, ax
mov es, ax
mov ah, 09h
mov dx, offset alphabetmy
int 21h
mov cx, 26
mov si, offset alphabetnew

lo1:
	mov ah, 08h
	int 21h
	mov byte ptr[si], al
	mov ah, 02h
	mov dl, al
	int 21h
	inc si
loop lo1
mov ah, 2
mov dl, 10
int 21h
mov ah, 09h
mov dx, offset params
int 21h
inparams:
		mov ah, 08h
		int 21h
		mov ah, 02h
		mov dl, al
		int 21h
		cmp al , 'l'
		jne outl
			or word ptr[ignoreflag], 1b
		outl:
		cmp al , 'u'
		jne outu
			or word ptr[ignoreflag], 10b
		outu:
		cmp al , 'o'
		jne outo
			or word ptr[ignoreflag], 100b
		outo:
		cmp al , 'v'
		jne outv
			or word ptr[ignoreflag], 1000b
		outv:
		cmp al , 'c'
		jne outc
			or word ptr[ignoreflag], 10000b
		outc:

		cmp al, 13
        je outparams

        cmp al, 10
        je outparams
jmp inparams
outparams:
mov ah, 2
mov dl, 10
int 21h

push ds
	mov ax, 3509h
	int 21h
	mov word ptr[old], bx 
	mov word ptr[old + 2], es 
	mov ax, 2509h
	mov dx, @code
	mov ds, dx             
	mov dx, offset change
	int 21h 
pop ds
f:

jmp f
end main
