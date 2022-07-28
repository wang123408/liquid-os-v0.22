; print.asm
; Copyright (C) zhouzhihao 2021-2022
; Powerint DOS 386

;Copyright (C) zhouzhihao 2021-2022
;Liquid-os-0.22

; 此文件包含以下函数：
; PutChar
; PutStr
; PutHexNumber
; Cons_PutChar
; Cons_PutStr
; Cons_NewLine
; Cons_PutHexNumber
; GetPos
; ChangePos
; NextScreenLine

PosInPort			equ		0x3d4
PosOutPort			equ		0x3d5
PosRegisterHigh		equ		0xe
PosRegisterLow		equ		0xf
PutChar:
; 打印字符
; IN：
; BH --> 行
; BL --> 列
; AL --> 字符
; AH --> 颜色
	push	edi
	push	ebx
	push	ax
	push	bx
	mov	al,bh
	mov	bl,160	; ysize * 160
	mul	bl
	pop	bx
	mov	di,ax
	mov	bh,0
	add	di,bx	; + xsize * 2
	add	di,bx
	and	edi,0000ffffh	; 只保留下半部分
	pop	ax
	mov	[es:TextVramAddrSegment+edi],ax
	pop	ebx
	pop	edi
	ret

PutStr:
; 打印字符串
; IN：
; BH --> 行
; BL --> 列
; DS:ESI --> 字符串地址
; AH --> 颜色
	mov	al,[esi]
	cmp	al,0
	je	.PutEnd
	cmp	al,0ah
	je	.NextLine
	cmp	al,0dh
	je	.LineStart
	cmp	al,08h
	je	.BackSpace
	push	ax
	push	bx
	call	PutChar
	pop	bx
	pop	ax
	inc	esi
	inc	bl
	cmp	bl,80	; 判断是否满1行
	jne	PutStr
	inc	bh
	mov	bl,0
	jmp	PutStr
.BackSpace:
	dec	bl
	inc	esi
	jmp	PutStr
.LineStart:
	mov	bl,0
	inc	esi
	jmp	PutStr
.NextLine:
	inc	bh
	inc	esi
	jmp	PutStr
.PutEnd:
	ret

PutHexNumber:
; 打印十六进制数字
; 寄存器：in:ESI/ECX/AH/BH/BL
; ESI --> 数字串地址
; ECX --> 数字串的长度
; AH --> 颜色
; BH --> 行
; BL --> 列
	mov	al,[esi]
	shr	al,4
	call	NumberToASCII
	push	ecx
	push	esi
	push	edi
	push	bx
	call	PutChar
	pop	bx
	inc	bl
	pop	edi
	pop	esi
	mov	al,[esi]
	and	al,0fh
	call	NumberToASCII
	push	esi
	push	edi
	push	bx
	call	PutChar
	pop	bx
	inc	bl
	pop	edi
	pop	esi
	pop	ecx
	inc	esi
	dec	ecx
	jecxz	.EndOfPut
	jmp	PutHexNumber
.EndOfPut:
	ret

Cons_PutChar:
; 打印字符（CmdCurYsize,CmdCurXsize）
; 寄存器：in:AL/AH
	mov	bh,[Console.CmdCurYsize]
	mov	bl,[Console.CmdCurXsize]
	call	PutChar
	inc	byte[Console.CmdCurXsize]
	ret

Cons_PutStr:
; 打印字符串（CmdCurYsize,CmdCurXsize）
; 寄存器：in:DS:ESI
	mov	bh,[Console.CmdCurYsize]
	mov	bl,[Console.CmdCurXsize]
	call	PutStr
	mov	[Console.CmdCurXsize],bl
	mov	[Console.CmdCurYsize],bh
	ret

Cons_NewLine:
; 换行（CmdCurYsize,CmdCurXsize）
; 无寄存器
	inc	byte[Console.CmdCurYsize]
	mov	byte[Console.CmdCurXsize],0
	ret

Cons_PutHexNumber:
; 打印十六进制数字（CmdCurYsize,CmdCurXsize）
; 寄存器：in:ESI/ECX/AH
; ESI --> 数字串地址
; ECX --> 数字串的长度
; AH --> 颜色
	mov	al,[esi]
	shr	al,4
	call	NumberToASCII
	push	ecx
	push	esi
	push	edi
	call	Cons_PutChar
	pop	edi
	pop	esi
	mov	al,[esi]
	and	al,0fh
	call	NumberToASCII
	push	esi
	push	edi
	call	Cons_PutChar
	pop	edi
	pop	esi
	pop	ecx
	inc	esi
	dec	ecx
	jecxz	.EndOfPut
	jmp	PutHexNumber
.EndOfPut:
	ret

GetPos:
; 得到光标位置
; 寄存器：out:AX
	push	dx
	mov	dx,PosInPort
	mov	al,PosRegisterHigh	; 得到光标位置高位
	out	dx,al
	mov	dx,PosOutPort
	in	al,dx
	mov	ah,al	; 放在AH中
	mov	al,PosRegisterLow	; 得到光标位置低位
	out	dx,al
	in	al,dx
	pop	dx
	ret

ChangePos:
; 改变光标位置
; 寄存器：in:AX
	push dx
	push bx
	mov bx,ax
	mov dx,PosInPort
	mov al,PosRegisterHigh
	out dx,al
	mov dx,PosOutPort
	mov al,bh
	out dx,al
	mov dx,PosInPort
	mov al,PosRegisterLow
	out dx,al
	mov dx,PosOutPort
	mov al,bl
	out dx,al
	mov ax,bx
	pop bx
	pop dx
	ret

NextScreenLine:
; 判断CmdCurYsize是否大于等于25，是就滚动CmdCurYsize-24行
; 计时器中断执行
	cmp	byte[Console.CmdCurYsize],25
	jae	.NextLine
	ret
.NextLine:
	push	eax
	push	esi
	push	edi
	push	ecx
	push	ds
	mov	al,[Console.CmdCurYsize]
	sub	al,24
	push	ax
	mov	ax,NormalSelector
	mov	ds,ax
	mov	esi,TextVramAddrSegment
	mov	edi,TextVramAddrSegment
	pop	ax
	mov	bl,160
	mul	bl
	and	eax,0000ffffh
	add	esi,eax
	mov	ecx,160*25
	call	MemCpy	; 把第二行拷贝至第一行，第三行拷贝至第二行...
	pop	ds
	pop	ecx
	pop	edi
	pop	esi
	pop	eax
	mov	byte[Console.CmdCurYsize],24
	ret