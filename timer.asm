; timer.asm
; Copyright (C) zhouzhihao 2021-2022
; Powerint DOS 386

;timer.asm
;Copyright (C) Liquid 2021 -2022
;Liquid-os-0.22

; 此文件包含以下函数：
; TimerHandler

TimerHandler:
; 计时器响应中断
	pushad
	mov	al,0x60
	out	PIC0_OCW2,al	; 通知PIC0 IRQ0中断处理完毕
	call	NextScreenLine
	mov	al,[Console.CmdCurYsize]
	mov	bl,80
	mul	bl
	add	al,byte[Console.CmdCurXsize]
	call	ChangePos
	popad
	iret