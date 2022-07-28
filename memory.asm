; memory.asm
; Copyright (C) zhouzhihao 2021-2022
; Powerint DOS 386

;memory.asm
;Copyright (C) liquid 2021-2022
;Liquid-os-0.22

; 此文件包含以下函数：
; MemCpy
; MemTest
; Malloc
; Free
; FreeMemKB
; MallocMemKB
; NumberToASCII

MemCpy:
; 拷贝内存到某处
; 寄存器：in:DS:ESI/ES:EDI/ECX
; DS:ESI --> 数据源地址
; ES:EDI --> 目的地址
; ECX --> 复制长度
	rep	movsb	; 传送字节数据直到ECX=0
	ret

MemTest:
; 内存大小测试
; 寄存器：in:EBX/EDX out:EBX
; EBX --> 内存测试地址开头
; EDX --> 最大测试内存地址
	mov	eax,cr0
	or	eax,0x60000000
	mov	cr0,eax
.MemTestLoop:
	mov	ebp,ebx
	mov	eax,[es:ebx]
	mov	dword[es:ebx],0x55aa55aa	; 试着写内存
	xor	dword[es:ebx],0xffffffff
	cmp	dword[es:ebx],0xaa55aa55
	jne	.MemNotOk
	xor	dword[es:ebx],0xffffffff
	cmp	dword[es:ebx],0x55aa55aa
	jne	.MemNotOk
	mov	[es:ebx],eax
	add	ebx,4	; 以4KB为单位 这样更高效
	cmp	ebx,edx
	jbe	.MemTestLoop
	mov	eax,cr0
	and	eax,0x9fffffff
	mov	cr0,eax
	ret
.MemNotOk:
	mov	[es:ebx],eax
	mov	ebx,ebp
	mov	eax,cr0
	and	eax,0x9fffffff
	mov	cr0,eax
	ret

Malloc:
; 分配内存
; 寄存器：in:EBX/EDX
; EBX --> 物理内存起始地址
; EDX --> 物理内存终止地址
	push	edx
	sub	edx,ebx
	mov	ebx,edx
	pop	edx
	shr	ebx,12
	mov	ax,bx
	mov	bl,8
	div	bl
	mov	ecx,0
	mov	cl,al
	
	shr	edx,12
	mov	ax,dx
	mov	bl,8
	div	bl
	mov	ebx,0
	mov	bl,al
.OrLoop:
	or	byte[es:MemManSegment+ebx],11111111b
	dec	ebx
	loop	.OrLoop
	ret

Free:
; 释放内存
; 寄存器：in:EBX/EDX
; EBX --> 物理内存起始地址
; EDX --> 物理内存终止地址
	push	edx
	sub	edx,ebx
	mov	ebx,edx
	pop	edx
	shr	ebx,12
	mov	ax,bx
	mov	bl,8
	div	bl
	mov	ecx,0
	mov	cl,al
	
	shr	edx,12
	mov	ax,dx
	mov	bl,8
	div	bl
	mov	ebx,0
	mov	bl,al
.AndLoop:
	and	byte[es:MemManSegment+ebx],00000000b
	dec	ebx
	loop	.AndLoop
	ret

MallocMemKB:
; 使用的内存（KB制）
; 寄存器：in:EAX out:EAX
; EAX --> Memory Manager的长度
	mov	ecx,eax
	mov	ebx,0
	mov	eax,0
.LoopOfCMP:
	cmp	byte[es:MemManSegment+ebx],11111111b
	jne	.NotMalloc
	add	eax,32	; 一个BYTE区块32KB
.NotMalloc:
	inc	ebx
	dec	ecx
	jecxz	.EndOfLoop
	jmp	.LoopOfCMP
.EndOfLoop:
	ret

FreeMemKB:
; 剩余可用内存（KB制）
; 寄存器：in:AX out:EAX
; AX --> Memory Manager的长度
	mov	ecx,eax
	mov	ebx,0
	mov	eax,0
.LoopOfCMP:
	cmp	byte[es:MemManSegment+ebx],00000000b
	jne	.NotFree
	add	eax,32	; 一个BYTE区块32KB
.NotFree:
	inc	ebx
	dec	ecx
	jecxz	.EndOfLoop
	jmp	.LoopOfCMP
.EndOfLoop:
	ret

NumberToASCII:
; 将数字化成ASCII码
; 寄存器：in:AL out:AL
	cmp	al,9	; 是否是英文字符
	ja	.Letter
	add	al,30h
	ret
.Letter:
	add	al,37h
	ret