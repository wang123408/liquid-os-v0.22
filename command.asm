;command.asm
;Copyright (C) liquid 2021-2022
;Liquid-os-0.22

FindCommand:
; 判断并执行命令
	mov	esi,0
	mov	cx,5
.LoopFind1:
	mov	ah,[Console.CmdLine+esi]
	mov	al,[VerCom+esi]
	cmp	al,ah
	jne	.LoopFind2r
	inc	esi
	loop	.LoopFind1
	jmp	uname
.LoopFind2r:
	mov	esi,0
	mov	cx,3
.LoopFind2:
	mov	ah,[Console.CmdLine+esi]
	mov	al,[ClsCom+esi]
	cmp	al,ah
	jne	.LoopFind3r
	inc	esi
	loop	.LoopFind2
	jmp	clear
.LoopFind3r:
	mov	esi,0
	mov	cx,4
.LoopFind3:
	mov	ah,[Console.CmdLine+esi]
	mov	al,[EchoCom+esi]
	cmp	al,ah
	jne	.LoopFind4r
	inc	esi
	loop	.LoopFind3
	jmp	echocommand
.LoopFind4r:
	mov	esi,0
	mov	cx,4
.LoopFind4:
	mov	ah,[Console.CmdLine+esi]
	mov	al,[FreeCom+esi]
	cmp	al,ah
	jne	.LoopFind5r
	inc	esi
	loop	.LoopFind4
	jmp	free
.LoopFind5r:
	mov	esi,0
	mov	cx,2
.LoopFind5:
	mov	ah,[Console.CmdLine+esi]
	mov	al,[lsCom+esi]
	cmp	al,ah
	jne	.LoopFind6r
	inc	esi
	loop	.LoopFind5
	jmp	ls
.LoopFind6r:
	mov	esi,0
	mov	cx,3
.LoopFind6:
	mov	ah,[Console.CmdLine+esi]
	mov	al,[TypeCom+esi]
	cmp	al,ah
	jne	.LoopFind7r
	inc	esi
	loop	.LoopFind6
	jmp	catcommand
.LoopFind7r:
	mov	esi,0
	mov	cx,4
.LoopFind7:
	mov	ah,[Console.CmdLine+esi]
	mov	al,[rootCom+esi]
	cmp	al,ah
	jne	.LoopFind8r
	inc	esi
	loop	.LoopFind7
	jmp root
.LoopFind8r:
	mov	esi,0
	mov	cx,4
.LoopFind8:
	mov	ah,[Console.CmdLine+esi]
	mov	al,[helpCom+esi]
	cmp	al,ah
	jne	.NotFind
	inc	esi
	loop	.LoopFind8
	jmp	help

.NotFind:
	mov	esi,0
.PutLoop:
	mov	si,BadCom
	mov	ah,07h
	call	Cons_PutStr
	ret
	
uname:
; ver命令
	call	Cons_NewLine
	mov	si,Version
	mov	ah,07h
	call	Cons_PutStr
	call	Cons_NewLine
	ret

cpuinfo:
	mov eax,0
	cpuid
	push ebx
	shr ebx,24
	mov dl,bl
	pop ebx
	push ebx
	shr ebx,16
	mov dh,bl
	pop ebx
	push ebx
	shr ebx,8
	mov cl,bl
	pop ebx
	mov ch,bl
	shl ecx,16
	and edx,0x0000ffff
	and ecx,0xffff0000
	or edx,ecx
	mov [edxdata],edx
	mov si,edxdata
	call Cons_PutStr
	ret
	
clear:
; clear命令
	mov	byte[Console.CmdCurYsize],0
	mov	byte[Console.CmdCurXsize],0
	mov	esi,0
	mov	cx,25*80
.MemWriteLoop:
	mov	byte[es:TextVramAddrSegment+esi],' '
	mov	byte[es:TextVramAddrSegment+esi+1],07h
	add	esi,2
	loop	.MemWriteLoop
	ret

help:
	call	Cons_NewLine
	mov	si,helpmsg
	mov	ah,07h
	call	Cons_PutStr
	call	Cons_NewLine
	ret
echocommand:
; echo命令
	mov	esi,5
.PutLoop:
	mov	al,[Console.CmdLine+esi]
	cmp	al,0
	je	.PutOK
	mov	ah,07h
	call	Cons_PutChar
	inc	esi
	jmp	.PutLoop
.PutOK:
	ret

free:
; free命令
	; 输出部分
	mov	esi,MemoryAMFPut
	mov	ah,07h
	call	Cons_PutStr
	call	Cons_NewLine
	; All部分
	mov	eax,[MemoryLargest]
	shr	eax,16
	mov	bx,4
	mul	bx		; (地址>>16)*4=KB制总内存（大约）
	mov	[Temp],dl
	mov	[Temp+1],ah
	mov	[Temp+2],al
	mov	ecx,3
	mov	esi,Temp
	mov	ah,07h
	call	PutHexNumber
	mov	bh,[Console.CmdCurYsize]
	dec	bh
	mov	bl,4
	ret

root:
    call startroot
	ret

ls:
; ls命令
	mov	esi,lsput
	mov	ah,07h
	call	Cons_PutStr
	call	Cons_NewLine
	call	Cons_NewLine
	
	mov	esi,FileInfoSegment
	mov	ecx,12
.LoopPutFileName:
	mov	al,[es:esi]
	mov	ah,07h
	call	Cons_PutChar
	inc	esi
	loop	.LoopPutFileName
	call	Cons_NewLine
	cmp	byte[es:esi+32-12],0
	je	.PutOK
	mov	ecx,12
	add	esi,32-12
	jmp	.LoopPutFileName
.PutOK:
	ret

catcommand:
; cat命令
	mov	esi,4
	mov	edi,0
.Copy:
	mov	al,[Console.CmdLine+esi]
	cmp	al,0
	je	.OK
	cmp	al,' '
	je	.OK
	mov	[Temp+edi],al
	inc	esi
	inc	edi
	jmp	.Copy
.OK:
	mov	esi,Temp
	mov	dh,20h	; 20h为文件
	call	FileNameCpy
	mov	esi,Temp
	call	FindFileLoop
	cmp	ebx,0
	je	.Notfind
	cmp	edi,0
	je	.Notfind
	mov	ecx,[es:ebx+28]
.PutLoop:
	mov	al,[es:edi]
	mov	ah,07h
	call	Cons_PutChar
	inc	edi
	dec	ecx
	jecxz	.Ret
	jmp	.PutLoop
.Ret:
	ret
.Notfind:
	mov	esi,NotFindPut
	mov	ah,07h
	call	Cons_PutStr
	call	Cons_NewLine
	ret