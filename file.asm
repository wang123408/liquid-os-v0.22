; file.asm
; Copyright (C) zhouzhihao 2022
; Powerint DOS 386

; file.asm
; Copyright (C) Liquid-os 2022
; Liquid-os-v0.22

; 此文件包含以下函数：
; FileNameCpy
; FindFileLoop

FileNameCpy:
; 将“文件名.后缀”的文件名格式转化成“文件名    后缀”的格式
; 寄存器：in:DS:ESI/DH out:[ESI]
; DS:ESI --> 文件名地址
; DH --> 文件属性
	mov	cx,9
.Loop:
	cmp	byte[esi],'.'
	je	.Dol
	cmp	byte[esi],0
	je	.Ret
	and	byte[esi],11011111b
	inc	esi
	loop	.Loop
.Ret:
	ret
.Dol:
	sub	cx,2
	mov	ebx,0
	mov	bx,cx
	mov	byte[esi],' '
	inc	esi	; 跳过空格
	
	mov	al,[esi+2]
	mov	byte[esi+2],' '
	and	al,11011111b
	mov	[esi+ebx+2],al
	mov	al,[esi+1]
	mov	byte[esi+1],' '
	and	al,11011111b
	mov	[esi+ebx+1],al
	mov	al,[esi]
	mov	byte[esi],' '
	and	al,11011111b
	mov	[esi+ebx],al
	mov	[esi+ebx+3],dh
	ret

FindFileLoop:
; 在内存中寻找文件
; 寄存器：in:DS:ESI out:ES:EBX/ES:EDI
; IN:
; DS:ESI --> 文件名地址
; OUT:
; ES:EBX --> 文件信息头地址
; ES:EDI --> 文件内容地址
	mov	edi,FileInfoSegment
	mov	cx,12
.LoopCMP:
	mov	al,[es:edi]
	mov	ah,[esi]
	cmp	al,ah
	jne	.NextFile
	inc	edi
	inc	esi
	loop	.LoopCMP
	; 计算文件信息头地址
	sub	edi,12
	mov	ebx,edi
	; 计算文件内容地址
	mov	cx,[es:ebx+26]
	mov	edi,0
.LoopCount:
	add	edi,200h
	loop	.LoopCount
	add	edi,FileAddrSegment
	ret
.NextFile:
	mov	eax,12
	sub	ax,cx
.LoopSubEnd:
	sub	edi,eax
	sub	esi,eax
	add	edi,32
	mov	cx,12
	mov	al,[es:edi]
	cmp	al,0
	jne	.LoopCMP
	mov	ebx,0	; 没找到文件 EBX、EDI置0
	mov	edi,0
	ret