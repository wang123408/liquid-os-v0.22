; input.asm
; Copyright (C) zhouzhihao 2021-2022

;input.asm
;Copyright (C) liquid 2021-2022
;Liquid-os-0.22

; 此文件包含以下函数：
; InitKeyBoard
; KeyBoardHandler
; WaitInput
; SaveInput

; Powerint DOS 386
KEYBOARD_DATA_PORT	equ	0x60
KEYBOARD_CMD_PORT	equ	0x64


KeyBoardCode1:	; KeyCode扫描码对照表1
	db	0,0,'1','2','3','4','5','6','7','8','9','0','-','='
	db	08h,0,'q','w','e','r','t','y','u','i','o','p','[',']'
	db	0dh,0,'a','s','d','f','g','h','j','k','l',';',"'","\"
	db	0,0,'z','x','c','v','b','n','m',',','.','/',0,'*'
	db	0,' ',0,0,0,0,0,0,0,0,0,0,0,0,0,'7','8','9','-','4','5','6','+','1','2','3','0','.'
KeyBoardCode2:	; KeyCode扫描码对照表2(shift)
	db	0,0,'!','@','#','$','%','^','&','*','(',')','_','+'
	db	08h,0,'Q','W','E','R','T','Y','U','I','O','P','{','}'
	db	0dh,0,'A','S','D','F','G','H','J','K','L',':','"','|'
	db	0,0,'Z','X','C','V','B','N','M','<','>','?',0,'*'
	db	0,' ',0,0,0,0,0,0,0,0,0,0,0,0,0,'7','8','9','-','4','5','6','+','1','2','3','0','.'


InitKeyBoard:
; 初始化键盘电路
; 无寄存器
	mov	al,0x60
	out	KEYBOARD_CMD_PORT,al
	mov	al,0x47	; 鼠标的电路
	out	KEYBOARD_DATA_PORT,al
	ret

KeyBoardHandler:
; 键盘发过来的中断
	push	ax
	mov	al,0x61
	out	PIC0_OCW2,al	; 通知PIC0 IRQ1中断处理完毕
	in	al,KEYBOARD_DATA_PORT
	cmp	al,0xaa		; Shift的松开码
	je	.LoosenShift
	cmp	al,0x80
	jae	.EndOfCMP
	cmp	al,0x2a		; Shift的按下码
	je	.PressShift
	cmp	al,0x3a		; Caps Lock的按下码
	je	.PressCapsLock
	push	esi
	push	edi
	push	ebx
	mov	esi,KeyBoardFIFO.FIFO
	call	FIFOInput
	pop	ebx
	pop	edi
	pop	esi
	or	byte[KeyBoardFlags],00000001b	; KeyBoardFlags>>0 = 1;
	jmp	.EndOfCMP
.PressShift:
	or	byte[KeyBoardFlags],00000010b	; KeyBoardFlags>>1 = 1;
	jmp	.EndOfCMP
.LoosenShift:
	and	byte[KeyBoardFlags],11111101b	; KeyBoardFlags>>1 = 0;
	jmp	.EndOfCMP
.PressCapsLock:
	xor	byte[KeyBoardFlags],00000100b	; KeyBoardFlags>>2 ^= 1;
.EndOfCMP:
	pop	ax
	iret

WaitInput:
; 等待性输入
; 寄存器：out:AL
; AL --> 输入的ASCII码
	mov	al,[KeyBoardFlags]
	and	al,00000001b
	cmp	al,00000001b	; 判断是否有输入
	jne	WaitInput
	cli		; 防止被打扰
	mov	al,[KeyBoardFlags]
	and	al,00000010b
	cmp	al,00000010b
	je	.Shift	; 按下Shift?
	mov	al,[KeyBoardFlags]
	and	al,00000100b
	cmp	al,00000100b
	je	.CapsLock	; 按下CapsLock?
	mov	esi,KeyBoardFIFO.FIFO
	call	FIFOOutput
	mov	bl,al
	mov	bh,0
	mov	al,[KeyBoardCode1+bx]
	sti
	and	byte[KeyBoardFlags],11111110b
	ret
.Shift:
.CapsLock:
	mov	esi,KeyBoardFIFO.FIFO
	call	FIFOOutput
	mov	bl,al
	mov	bh,0
	mov	al,[KeyBoardCode2+bx]
	sti
	and	byte[KeyBoardFlags],11111110b
	ret
	
SaveInput:
; 查询性输入
; 寄存器：out:AL
; AL --> 输入的ASCII码
	mov	esi,KeyBoardFIFO
	call	FIFOOutput
	ret