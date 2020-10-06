.model small
.stack 100h
.data
	sort_arr db 125 dup(0)
	arr db 125 dup(?)
	leng dw 0
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

read_string proc C near
arg string:word, len:word
uses ax, bx, cx
    mov bx, string
    mov si, 0

    readingS:
        call read_char C
        cmp cl, 13
        je readSE

        cmp cl, 10
        je readSE

        mov [bx + si], cl
        
        inc si
        call print_char C
        jmp readingS

    readSE:
    mov byte ptr [bx + si], '$'
    
    mov bx, len
    mov [bx], si
    ret
endp 

print_string proc C near
arg string:word
uses ax, dx
    mov ah, 09h
    mov dx, string
    int 21h
    ret
endp

main:
	mov ax, @data
	mov ds, ax
	call read_string C, offset arr, offset leng
	mov ax, 0
	mov cx, [leng]
	mov si, 0
	L1:
		mov di, offset sort_arr
		mov al, arr[si]
	
		add di, ax
		inc byte ptr [di]
		inc si
	loop L1
	
	mov cx, 124
	mov si, 0
	mov di, offset arr
	L2:
		cmp sort_arr[si], 0
		jz exL2
			dec sort_arr[si]
			mov [di], si
			inc di
			jmp L2
		exL2:
		inc si
	loop L2
	mov [di], '$'

	call print_string C, offset arr

	call read_string C, offset arr, offset leng
	mov ax, 4c00h
	int 21h

end main