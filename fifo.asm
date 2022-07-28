; fifo.asm
; Copyright (C) zhouzhihao 2021-2022
; Powerint DOS 386

;copyright (C) 2021-2022 Liquid-os
;特别感谢b站up主：main0911、xp用户123、yywd123和菱角os的帮助

; 此文件包含以下函数：
; FIFOInput
; FIFOOutput

%macro	FIFO256	2
; 8位FIFO信息 缓冲区长度上限256Bytes
	dd	%1	; BufferPointer
	db	%2	; BufferLength
	db	0	; Next_Write
	db	0	; Next_Read
	db	%2	; BufferFree
%endmacro

FIFOInput:
; 将数据存入缓冲区
; 寄存器：in:AL/ESI
; AL --> 存入的数据
; DS:ESI --> FIFO信息地址
	cmp	byte[esi+7],0	; if (BufferFree == 0)
	je	.EndOfInput
	mov	edi,[esi]
	mov	ebx,0
	mov	bl,[esi+5]
	cmp	bl,byte[esi+4]	; if (Next_Read == BufferLength)
	je	.Overflow
	mov	[edi+ebx],al
	inc	byte[esi+5]	; Next_Write++
	dec	byte[esi+7]	; BufferFree--
	ret
.Overflow:	; 溢出情况
	mov	byte[esi+5],0
	mov	ebx,0
	mov	bl,[esi+5]
	mov	[edi+ebx],al
	inc	byte[esi+5]
	dec	byte[esi+7]
.EndOfInput:
	ret

FIFOOutput:
; 将缓冲区数据读出
; 寄存器：in:ESI out:AL
; DS:ESI --> FIFO信息地址
	mov	al,[esi+4]
	cmp	byte[esi+7],al	; if (BufferFree == BufferLength)
	je	.EndOfOutput
	mov	edi,[esi]
	mov	ebx,0
	mov	bl,[esi+6]
	cmp	bl,byte[esi+4]	; if (Next_Read == BufferLength)
	je	.Overflow
	mov	al,[edi+ebx]
	inc	byte[esi+6]	; Next_Read++
	inc	byte[esi+7]	; BufferFree++
	ret
.Overflow:	; 溢出情况
	mov	byte[esi+6],0
	mov	ebx,0
	mov	bl,[esi+6]
	mov	al,[esi+ebx]
	inc	byte[esi+6]
	inc	byte[esi+7]
.EndOfOutput:
	mov	al,0
	ret