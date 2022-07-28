; loader.asm
; Copyright (C) zhouzhihao 2021
; Powerint DOS 386

;loader.asm
;Copyright (C) liquid 2021-2022
;Liquid-os-0.22

jmp	near	start
%include "gdt.inc"
%include "addr.inc"
GDT_BASE:	Descriptor	0,0,0
GDT_CODE:	Descriptor	CommandSegment,0fffffh,DA_C | DA_32 | DA_LIMIT_4K
GDT_DATA:	Descriptor	CommandSegment,0fffffh,DA_DRW | DA_32
GDT_STACK:	Descriptor	BaseOfStack,TopOfStack-BaseOfStack,DA_DRW | DA_32
GDT_NORMAL:	Descriptor	0,0fffffh,DA_DRW | DA_32 | DA_LIMIT_4K

GDT_LEN	equ	$ - GDT_BASE
GDT_PTR:
	dw	GDT_LEN
	dd	GDTAddrSegment

start:
	mov	ax,cs
	mov	ds,ax
	
	mov	sp,BaseOfStack
	mov	ss,sp
	mov	sp,TopOfStack
	
	mov	si,FindFileName
	call	FindFile
	cmp	ah,0	; 没找到的情况
	jne	next
	
	mov	si,ErrorMsg
	call	PutStr
	jmp	$

next:	; 计算文件段地址
	mov	ax,es
	add	ax,1h
	mov	es,ax
	mov	cx,[es:10]
	mov	ax,0
.mul:
	add	ax,20h
	loop	.mul
	add	ax,FileAddrSegment / 10h
	push	ax

	; 拷贝KERNEL.BIN至0x35000处
	pop ax
	mov	ds,ax
	mov	si,0
	mov	ax,CommandSegment / 10h
	mov	es,ax
	mov	di,0
	mov	cx,CommandLength
	call	MemCpy
	
	; 拷贝GDT至0x45000处
	mov	ax,cs
	mov	ds,ax
	mov	si,GDT_BASE
	mov	ax,GDTAddrSegment / 10h
	mov	es,ax
	mov	di,0
	mov	cx,GDTLength
	call	MemCpy
	
	lgdt	[GDT_PTR]	; 加载GDT

	in	al,92h
	or	al,00000010b
	out	92h,al
	
	cli		; 保护模式无BIOS中断
	mov	eax,cr0		; 拉开CR0寄存器
	and	eax,0x7fffffff
	or	eax,1
	mov	cr0,eax

	jmp	dword CodeSelector:0
	
FindFile:
; 巡查是否有指定的文件
; 寄存器：in:SI out:ES/AH
; SI --> 文件名地址
; AH=1找到 AH=0未找到
	mov	ax,FileInfoSegment	/ 10h
	mov	es,ax
	sub	di,di
	mov	cx,11
.Loop:
	mov	ah,[si]
	mov	al,[es:di]
	cmp	ah,al
	jne	.Next
	inc	si
	inc	di
	loop	.Loop
	mov	ah,1	; 找到！
	ret
.Next:
	mov	ax,es
	add	ax,2h
	mov	es,ax
	sub	di,di
	mov	al,[es:di]
	cmp	al,0
	je	.End
	mov	cx,11
	jmp	.Loop
.End:
	mov	ah,0	; 未找到！
	ret

PutStr:
; 打印字符串
; 寄存器：in:SI
	mov	al,[si]
	cmp	al,0
	je	.end
	mov	ah,0eh
	int	10h
	inc	si
	jmp	PutStr
.end:
	ret

MemCpy:
; 拷贝内存到某处
; 寄存器：in:DS:SI/ES:DI/CX
	mov	al,[ds:si]
	mov	[es:di],al
	inc	si
	inc	di
	loop	MemCpy
.cpyend:
	ret

FindFileName		db	'KERNEL  BIN'
ErrorMsg: 
		db	'If you see this that mean your computer have some problem!',0dh,0ah
		db  'You can restart your computer.',0dh,0ah
		db  'If this screen appears again you can rebuild Liquid-os-v0.22.',0dh,0ah		
		db	'Error Message: Boot_No KERNEL .BIN.',0dh,0ah
		db  'You can get help on QQ-mail:2804966657@qq.com.',0dh,0ah  ;blue screen