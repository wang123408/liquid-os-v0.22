; gdt.inc
; Copyright (C) zhouzhihao 2021-2022
; Powerint DOS 386
; GDT描述符（64位）
%macro Descriptor 3	
; 段基址（起始地址）、段界限（大小）、属性
	dw	%2 & 0ffffh	; 参数2的低16位填充1个16位
	dw	%1 & 0ffffh	; 参数1的低16位填充1个16位
	db	(%1 >> 16) & 0ffh	; 参数1的17-25位填充1个8位
	dw	((%2 >> 8) & 0f00h) | (%3 & 0f0ffh)	; 参数2的17-21位和参数3的1-8位和13-16位填充1个16位
	db	(%1 >> 24) & 0ffh	; 参数1的25-32位填充个16位
	; 分析后 可用位置为（F为可用）
	; 段基址 0xFFFFFFFF
	; 段界限 0x000FFFFF
	; 属性 0x0000F0FF
%endmacro
DA_32		equ	4000h	; 32位段
DA_LIMIT_4K	equ	8000h	; 4K为单位
DA_DR		equ	90h	; 存在的只读数据段类型值
DA_DRW		equ	92h	; 存在的可读写数据段属性值
DA_DRWA		equ	93h	; 存在的已访问可读写数据段类型值
DA_C		equ	98h	; 存在的只执行代码段属性值
DA_CR		equ	9ah	; 存在的可执行可读代码段属性值
DA_CCO		equ	9ch	; 存在的只执行一致代码段属性值
DA_CCOR		equ	9eh	; 存在的可执行可读一致代码段属性值

CodeSelector	equ	0x0008
DataSelector	equ	0x0010
StackSelector	equ	0x0018
NormalSelector	equ	0x0020