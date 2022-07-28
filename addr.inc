; addr.inc
; Copyright (C) zhouzhihao 2021-2022
; Powerint DOS 386
; Powerint DOS 386 内存规划表：
; 0x0000 ~ 0x1000
; 0x1000 ~ 0x7C00      堆栈
; 0x7C00 ~ 0x7E00      引导扇区
; 0x7E00 ~ 0x8000
; 0x8000 ~ 0x35000     软盘
; 0x35000 ~ 0x45000    系统
; 0x45000 ~ 0x55000    GDT
; 0x55000 ~ 0x55400    IDT
; 0x55400 ~ 0x6D400    内存管理
; 0x6D400 ~ 0x7D400    软件
; 0x7D400 ~ 0xA0000
; 0xA0000 ~ 0x100000   低端显存
; 0x100000 ~
BaseOfStack				equ	0x1000			; 堆栈栈底
TopOfStack				equ	0x7c00			; 堆栈栈顶
GDTAddrSegment			equ	0x45000			; GDT地址
GDTLength				equ	0xffff			; GDT大小
CommandSegment			equ	0x35000			; COMMAND.BIN地址
CommandLength			equ	0xffff			; COMMAND.BIN大小
FileInfoSegment			equ	2600h + 8000h	; 文件信息区地址
FileAddrSegment			equ	3e00h + 8000h	; 文件内容区地址
TextVramAddrSegment		equ	0xb8000			; 文字模式显存地址
GraphicVramAddrSegment	equ	0xa0000			; 图形模式显存地址
IDTAddrSegment			equ	0x55000			; IDT地址
IDTLength				equ	0x400			; IDT大小
MemManSegment			equ	0x55400			; Memory Manager地址
MemManLargest			equ	0x18000			; Memory Manager最大值