; command.asm
; Copyright (C) Liquid 2021-2022
; 特别感谢b站up主：main0911、xp用户123、yywd123和菱角os的帮助

[BITS 32]
jmp	start
%include "gdt.inc"
%include "addr.inc"

IDT_BASE:
IDT_TIMER:
	dw	TimerHandler
	dw	CodeSelector
	dd	0x8e00
IDT_KEYBOARD:
	dw	KeyBoardHandler
	dw	CodeSelector
	dd	0x8e00
IDT_CPYLEN	equ	$ - IDT_BASE
IDT_PTR:
	dw	IDTLength	; 大小
	dd	IDTAddrSegment	; 地址

start:
	; 初始化所有段寄存器
	; DS --> DataSelector
	; ES,FS,GS --> NormalSelector
	mov	ax,DataSelector
	mov	ds,ax
	mov	ax,NormalSelector
	mov	es,ax
	mov	fs,ax
	mov	gs,ax
	mov	ax,StackSelector
	mov	ss,ax
	mov	sp,TopOfStack-BaseOfStack
	
	; 将IDT拷贝至0x55000处
	mov	esi,IDT_BASE
	mov	edi,IDTAddrSegment + 32*8
	mov	ecx,IDTLength
	call	MemCpy
	
	lidt	[IDT_PTR]	; 加载IDT
	
	call	InitPIC		; 初始化PIC
	call	InitPIT		; 初始化PIT
	call	InitKeyBoard	; 初始化键盘电路
	mov	al,11111000b	; 拉开键盘中断和计时器中断
	out	PIC0_OCW1,al
	
	sti	; 开启外部中断
	
	cli	; 测试内存关闭外部中断
	mov	ebx,0x100000
	mov	edx,0xbfffffff
	call	MemTest		; 测试1MB~3GB的空闲内存 得到最大内存地址
	sti	; 测试完毕打开外部中断
	
	mov	[MemoryLargest],ebx	; 保存

	; 计算出Memory Manager的大小
;	mov	ax,bx
;	shr	ebx,16
;	mov	dx,bx
;	mov	bx,0x8000	; 一个区块4KB 用位来管理
;	div	bx
;	mov	bx,dx
;	shl	ebx,16
;	mov	bx,ax
;	cmp	ebx,MemManLargest
;	ja	$
;	mov	[MemoryManagerLength],ebx
	
;	mov	ebx,0x1000
;	mov	edx,0x7e00
;	call	Malloc	; 堆栈+引导扇区占用
	
;	mov	ebx,0x8000
;	mov	edx,0x7D400
;	call	Malloc	; 软盘+系统+GDT+IDT+内存管理占用
	mov	bh,0
	mov	bl,0
	mov	ah,07h
	mov	esi,WelcomeMessage
	call	PutStr
	
	mov	esi,LinePut
	mov	bh,[Console.CmdCurYsize]
	mov	bl,0
	mov	ah,07h
	call	PutStr

	mov	esi,0

startroot:
	mov	esi,rootLinePut
	mov	bh,[Console.CmdCurYsize]
	mov	bl,0
	mov	ah,07h
	call	PutStr

	mov	esi,0
	
UserInput:
	push	esi
	call	WaitInput
	pop	esi
	cmp	al,08h	; 退格的处理
	je	.BackSpace
	cmp	al,0dh	; 换行的处理
	je	.Enter
	mov	ah,07h
	call	Cons_PutChar
	mov	[Console.CmdLine+esi],al
	inc	esi
	jmp	UserInput
.BackSpace:
	cmp	byte[Console.CmdCurXsize],18
	je	UserInput
	sub	byte[Console.CmdCurXsize],2
	mov	ah,07h
	mov	al,20h
	call	Cons_PutChar
	dec	esi
	mov	byte[Console.CmdLine+esi],0
	jmp	UserInput
.Enter:
	call	Cons_NewLine
	mov	byte[Console.CmdCurXsize],0		; 执行程序时Xsize必须为0
	call	FindCommand
	call	Cons_NewLine
	mov	bh,[Console.CmdCurYsize]
	mov	bl,0
	mov	si,LinePut
	mov	ah,07h
	call	PutStr
	mov	byte[Console.CmdCurXsize],18
	call	CleanCmdLineTemp
	mov	esi,0
	jmp	UserInput
	
%include "print.asm"	; 输出模块
%include "input.asm"	; 输入模块
%include "pic.asm"		; PIC中断模块
%include "fifo.asm"		; FIFO缓冲区模块
%include "timer.asm"	; 计时器模块
%include "memory.asm"	; 内存模块
%include "file.asm"		; 文件模块
%include "command.asm"	; 命令判断模块
%include "string.asm"	; 字符串模块

CleanCmdLineTemp:
; 清空命令行输入的和Temp中的数据
; 无寄存器
	mov	cx,128
	mov	si,0
.LoopClean:
	mov	byte[Console.CmdLine+si],0
	inc	si
	loop	.LoopClean
	mov	cx,16
	mov	si,0
.LoopClean2:
	mov	byte[Temp+si],0
	inc	si
	loop	.LoopClean2
	ret

Temp					times	128	db	0	; 临时存放地址
MemoryLargest			dd	0	; 最大内存地址
;MemoryManagerLength		dd	0	; 内存管理长度

KeyBoardFIFO:
.FIFO:		FIFO256	.Buffer,32
.Buffer:	times	32	db	0
KeyBoardFlags		db	0
; KeyBoardFlags：
; 第0位 --> 输入状态（1：输入 0：无输入）
; 第1位 --> Shift状态（1：按下 0：无按下）
; 第2位 --> Caps Lock状态（1：按下 0：无按下）
; 第3位 --> Num Lock状态（1：按下 0：无按下）
; 第4位 --> Scroll Lock状态（1：按下 0：无按下）
; 第5~7位 未定