.model small
.stack 100h
.data
mess db '1 - Очистка',13,10
     db '2 - Вывод сообщения',13,10
     db '3 - Ввод сообщения без подмены',13,10
     db '4 - Ввод сообщения с подменой',13,10
     db '5 - Выход','$'
smes dw 0
segm dw 0
sc db 0
message db 19,?,19 dup (?),'$'
.code
new_int proc far ;новое прерывание, которое просто вызывает старое
cli
pushf
;mov ax,@data
;mov es,ax
;mov si,offset smes
;call dword ptr es:[si]
call dword ptr cs:[smes]
sti
iret
new_int endp
clear proc ; процедура очистки консоли
push bp
mov bp,sp
mov ah,6
mov al,0
mov bx,[bp+8]
mov dx,[bp+6]
mov cx,[bp+4]
int 10h
pop bp
ret 6
clear endp
poscurs proc ;процедура позиционирования курсора
push bp
mov bp,sp
mov ah,2
mov bh,0
mov dx,[bp+4]
int 10h
pop bp
ret 2
poscurs endp
WriteMess proc ; вывод сообщения с помощью 9 функции 21 прерывания
push bp
mov bp,sp
mov ah,9
mov dx,[bp+4]
int 21h
pop bp
ret 2
WriteMess endp
InString proc ; ввод сообщения с помощью функции 0ah 21 прерывания
push bp
mov bp,sp
mov ah,0ah
mov dx,[bp+4]
int 21h
pop bp
ret 2
InString endp
start:
mov ax,@data
mov ds,ax
mov dl,0
mov dh,1
push dx
call poscurs
lea dx,mess
push dx
call WriteMess ;вывели меню
@on:
mov ah,8 
int 21h ;ждем нажатия
cmp al,49 ;анализируем цифру
jne @n1 
mov bh,00000111b ; 1 - очистка консоли
mov bl,0
push bx
mov dh,24
mov dl,79
push dx
mov ch,0
mov cl,40
push cx
call clear
jmp @on
@n1:
cmp al,50
jne @n2
mov dh,3 ; 2 - вывод сообщения
mov dl,45
push dx
call poscurs
lea dx,message
add dx,2
push dx
call WriteMess
jmp @on
@n2:
cmp al,51
jne @n3
mov dh,3 ;ввод сообщения
mov dl,45
push dx
call poscurs
lea dx,message
push dx
call InString
lea si,message
mov dx,si
add dl,ds:[si][1]
inc dx
inc dx
mov si,dx
mov byte ptr ds:[si],'$'
jmp @on
@n3:
cmp al,52
jne @n4
mov dh,3 ; подмена и ввод
mov dl,45
push dx
call poscurs
cli
mov ax,0
mov es,ax
mov si,9
shl si,2
mov dx,es:[si]
mov bx,es:[si+2]
mov segm,bx
mov smes,dx
mov ax,seg new_int
lea dx,new_int
mov es:[si],dx
mov es:[si+2],ax
sti
lea dx,message
push dx
call InString
lea si,message
mov dx,si
add dl,ds:[si][1]
inc dx
inc dx
mov si,dx
mov byte ptr ds:[si],'$'
cli
mov ax,0
mov es,ax
mov dx,smes
mov bx,segm
mov si,24h
mov es:[si],dx
mov es:[si+2],bx
sti
jmp @on
@n4:
cmp al,53
je @n5
jmp @on
@n5:
mov ah,4ch
int 21h
end start