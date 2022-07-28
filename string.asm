;command.asm
;Copyright (C) liquid 2021-2022
;Liquid-os-0.22

WelcomeMessage:
	db  '+-----------------------------------------------------------------------------+',0dh,0ah
	db	'|Welcome to Liquid-OS kernel v0.22 PE!                                        |',0dh,0ah
    db	'|Copyright (C) Liquid-OS 2021-2022                                            |',0dh,0ah 
	db  '+-----------------------------------------------------------------------------+',0dh,0ah
	db  '  _      _             _     _                  ',0dh,0ah
	db  ' | |    (_)           (_)   | |                 ',0dh,0ah
	db  ' | |     _  __  _ _   _ _  _| |______ ___  ___  ',0dh,0ah
	db  ' | |    | |/ _` | | | | |/ _` |______/ _ \/ __| ',0dh,0ah
	db  ' | |____| | (_| | |_| | | (_| |     | (_) \__ \ ',0dh,0ah
	db  ' |______|_|\__, |\__,_|_|\__,_|      \___/|___/ ',0dh,0ah
	db  '              | |                               ',0dh,0ah     
	db  '              |_|                               ',0dh
LinePut					db	'[User@Liquid-OS]$',0 
rootLinePut			    db	'[User@Liquid-OS]#',0 ;root
Console:
	.CmdLine					times	128	db	0	; 输入的命令行
	.CmdCurYsize				db	12
	.CmdCurXsize				db	17
BadCom					db	'Command not found',0
VerCom					db	'uname'
ClsCom					db	'clear'
EchoCom					db	'echo'
FreeCom					db	'free'
MemoryAMFPut			db	'All:000000KB  Malloc:000000KB  Free:000000KB',0
lsCom					db	'ls'
lsput       			db	'List Files',0
TypeCom					db	'cat'
helpCom					db	'help'
NotFindPut				db	'File not find.',0
rootCom				    db  'root'
edxdata dd 0
Version:
    db	'Liquid-OS kernel v0.22 PE',0dh,0ah
	db  'Built on Windows 10 and Ubuntu Linux with vscode,edimg and nasm.',0dh,0ah
	db  'QQ Email:2804966657@qq.com',0dh,0
helpmsg:
	db  '[uname  ]  The version of the System.',0dh,0ah
	db  '[ls     ]  List files of the System.',0dh,0ah
	db  '[echo   ]  Print the words.' ,0dh,0ah
	db  '[free   ]  The ram of the computer.',0dh,0ah
	db  '[clear  ]  Clear the screen.',0dh,0ah
	db  '[cat    ]  Open the files.',0dh,0ah
	db  '[cpuinfo]  The version of the CPU.',0dh,0ah
	db  '[root   ]  Superuer permissions.',0dh,0