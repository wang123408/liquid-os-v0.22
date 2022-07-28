; pic.asm
; Copyright (C) zhouzhihao 2021-2022
; Powerint DOS 386

;Copyright (C) Liquid-os 2021-2022
;Liquid-os-0.22

; 此文件包含以下函数：
; InitPIC
; InitPIT

; PIC相关设定
PIC0_ICW1	equ	0x20
PIC0_ICW2	equ	0x21
PIC0_ICW3	equ	0x21
PIC0_ICW4	equ	0x21
PIC1_ICW1	equ	0xa0
PIC1_ICW2	equ	0xa1
PIC1_ICW3	equ	0xa1
PIC1_ICW4	equ	0xa1
PIC0_OCW1	equ	0x21
PIC0_OCW2	equ	0x20
PIC1_OCW1	equ	0xa1
PIC1_OCW2	equ	0xa0
; 主PIC（PIC0）：
; IRQ0   -->   计时器
; IRQ1   -->   键盘
; IRQ2   -->   连接从PIC（PIC1）
; IRQ3   -->   串口设备
; IRQ4   -->   串口设备
; IRQ5   -->   声卡
; IRQ6   -->   软驱
; IRQ7   -->   打印机

; 从PIC（PIC1）：
; IRQ8   -->   时钟
; IRQ9   -->   连接主PIC（PIC0）
; IRQ10  -->   网卡
; IRQ11  -->   显卡
; IRQ12  -->   鼠标
; IRQ13  -->   协处理器
; IRQ14  -->   主硬盘
; IRQ15  -->   从硬盘

; PIT相关设定
PIT_CTRL	equ	0x43
PIT_CNT0	equ	0x40

InitPIC:
; 初始化PIC
; 无寄存器
	mov	al,011h
	out	PIC0_ICW1,al
	out	PIC1_ICW1,al
	mov	al,020h
	out	PIC0_ICW2,al
	mov	al,028h
	out	PIC1_ICW2,al
	mov	al,004h
	out	PIC0_ICW3,al
	mov	al,002h
	out	PIC1_ICW3,al
	mov	al,001h
	out	PIC0_ICW4,al
	out	PIC1_ICW4,al
	mov	al,11111011b
	out	PIC0_OCW1,al
	mov	al,11111111b
	out	PIC1_OCW1,al
	ret

InitPIT:
; 初始化PIT
; 无寄存器
	mov	al,0x34
	out	PIT_CTRL,al
	mov	al,0x9c
	out	PIT_CNT0,al
	mov	al,0x2e
	out	PIT_CNT0,al
	ret