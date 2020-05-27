TITLE CS2810 Assembler Template

; Student Name:
; Assignment Due Date:

INCLUDE Irvine32.inc
.data
	vHead WORD	1905h
	vSnake WORD 1B05h,1A05h, 5000 DUP(0)
	vSize WORD 2

	vFood WORD	0000h

	vNextDir BYTE "W",0
	vHeadDir BYTE "W",0

	vDelayTime DWORD 160000h	;The least significant WORD is unused.

	vWidth BYTE 30h
	vHeight BYTE 1Ch
	vHideCur WORD ?

	vSizeMessage BYTE "SNAKE SIZE: 00",0
	vLoseMessage BYTE "YOU LOSE!!",0
.code
main PROC
	
	CALL Clrscr

	;Put snake in intitial location
	MOV ax, 02h		;Green snake
	CALL SetTextColor

	MOV dx, 1A05h
	CALL GotoXY
	MOV al, "0"
	CALL WriteChar

	MOV dx, 1B05h
	CALL GotoXY
	CALL WriteChar
	
	;ADD Walls.

	MOV cl, vWidth
	MOV	ch, vHeight

	MOV dx, cx
	ADD dx, 0100h
	MOV vHideCur, dx
	MOV dx, 0001h

	MOV ax, 06h		;Brown walls
	CALL SetTextColor

	MOV al, 205	;205 is the hoizontal wall ASCII value
dHorWall:
	MOV dh, 00h
	CALL GotoXY
	CALL WriteChar

	MOV dh, ch
	CALL GotoXY
	CALL WriteChar

	ADD dl, 1

	CMP cl, dl
	JNZ dHorWall

	MOV dx, 0100h

	MOV al, 186	;186 is the Vertical wall ASCII Value
dVerWall:
	MOV dl, 00h
	CALL GotoXY
	CALL WriteChar

	MOV dl, cl
	CALL GotoXY
	CALL WriteChar

	ADD dh, 1

	CMP ch, dh
	JNZ dVerWall

; Corners
	MOV dx, 0000h
	MOV al, 201		;Top left corner ASCII value
	CALL GotoXY
	CALL WriteChar

	MOV dl, cl
	MOV al, 187		;Top right corner ASCII value
	CALL GotoXY
	CALL WriteChar

	MOV dh, ch
	MOV al, 188		;Bottom right corner ASCII value
	CALL GotoXY
	CALL WriteChar

	MOV dl, 00h
	MOV al, 200		;Bottom left corner ASCII value
	CALL GotoXY
	CALL WriteChar

	CALL Randomize
dEatFood:
	XOR eax, eax
	MOV al, vWidth
	SUB eax, 2
	CALL RandomRange
	MOV dl,al
	MOV al, vHeight
	SUB eax, 2
	CALL RandomRange
	MOV dh, al
	ADD dx, 0101h
	MOV vFood, dx

	MOV bx, vHead
	CMP bx, dx
	JZ dEatFood


	MOV cx, vSize
	MOV ebx, offset vSnake
dFoodInside:
	MOV ax, word ptr [ebx]
	CMP ax, dx
	JZ dEatFood

	ADD ebx, 2
	SUB cx, 1
	CMP cx, 0
	JNZ dFoodInside

	MOV bx, vSize
	ADD bx, 1
	MOV vSize, bx	

	MOV ax, 04h		;Red Food
	CALL SetTextColor

	MOV al, "#"
	CALL GotoXY
	CALL WriteChar

	MOV ax, 09h		;Cyan Snake Size
	CALL SetTextColor

	MOV dx, vHideCur
	XOR dl, dl
	CALL GotoXY

	MOV edx, offset vSizeMessage
	MOV ax, vSize
	MOV bx, 10
	DIV bl
	ADD ax, "00"
	MOV BYTE ptr [edx + 12] ,al
	MOV BYTE ptr [edx + 13] ,ah
	CALL WriteString

	MOV ax, 02h		;Green Snake
	CALL SetTextColor

	MOV ecx, vDelayTime
	SUB ecx, 10000h
	MOV vDelayTime, ecx

	MOV dx, vHideCur
	CALL GotoXY


dGameRunning:
	MOV ecx, vDelayTime
dUserInput:
	MOV eax, 10	
	CALL Delay	;delays 10 ms

	CALL ReadKey	;W 77h
					;A 61h
					;S 73h
					;D 64h

	MOV bl,vHeadDir
	CMP al, "W"	;W
	JZ dWKey
	CMP al, "A"	;A
	JZ dAKey
	CMP al, "S"	;S
	JZ dSKey
	CMP al, "D"	;D
	JZ dDkey
	CMP al, "w"	;W
	JZ dWlKey
	CMP al, "a"	;A
	JZ dAlKey
	CMP al, "s"	;S
	JZ dSlKey
	CMP al, "d"	;D
	JNZ dLoop

	MOV al, "D"
dDKey:
	CMP bl, "A"	;not A
	JZ dLoop
	JMP dChange
dWlKey:
	MOV al, "W"
dWKey:
	CMP bl, "S"	;not S
	JZ dLoop
	JMP dChange
dAlKey:
	MOV al, "A"
dAKey:
	CMP bl, "D"	;not D
	JZ dLoop
	JMP dChange
dSlKey:
	MOV al, "S"
dSKey:
	CMP bl, "W"	;not W
	JZ dLoop 	

dChange:
	MOV vNextDir, al
dLoop:
	SUB ecx, 10000h
	CMP ecx, 10000h
	JGE dUserInput
	
	
	XOR eax,eax
	MOV ax, vSize
	MOV cl, 2
	SUB ax, 1
	MUL cl
	MOV ecx, offset vSnake

	ADD ecx, eax

	MOV dx, vHead
	MOV WORD ptr[ecx], dx

	MOV bl, vNextDir
	;MOV vOut, bl
	MOV vHeadDir,bl


	MOV al, "0"
	CALL GotoXY
	CALL WriteChar
	
	;MOV edx, offset vOut
	;MOV ecx, 1
	;MOV eax, vFile
	;CALL WriteToFile

	MOV dx, vHead
	MOV al, vHeadDir
	

	CMP al, "W"	;W
	JZ dMoveW
	CMP al, "A"	;A
	JZ dMoveA
	CMP al, "S"	;S
	JZ dMoveS
dMoveD:
	ADD dx, 0001h
	JMP dAddHead
dMoveW:
	SUB dx, 0100h
	JMP dAddHead
dMoveA:
	SUB dx, 0001h
	JMP dAddHead
dMoveS:
	ADD dx, 0100h
	JMP dAddHead
dAddHead:

	CALL GotoXY
	MOV vHead, dx
	MOV al, "@"
	CALL WriteChar

	MOV bx, vFood
	CMP dx, bx
	JZ dEatFood
	
	;			------------------------------------------------------------------------------------------------------------------------
	;TODO: check if snake ran into wall or itself.

	CALL dInItself	;dx holds vHead
	CALL dInAWall	;dx contains vHead

	MOV dx, vSnake
	CALL GotoXY
	MOV al, " "
	CALL WriteChar

	MOV edx, offset vSnake	
	MOV ebx, edx
	ADD edx, 2


	MOV cx, vSize
dSaveSnake:

	MOV ax, word ptr [edx]	
	MOV word ptr [ebx], ax


	ADD edx, 2
	ADD ebx, 2
	SUB cx, 1
	CMP cx, 0
	JNZ dSaveSnake
	
	MOV dx, vHideCur
	CALL GotoXY

JMP dGameRunning	

dInItself:	;dx contains head
	MOV ebx, offset vSnake	
	MOV cx, vSize
dItselfLoop:

	MOV ax, word ptr [ebx]	
	CMP ax, dx
	JZ dEndGame

	ADD ebx, 2
	SUB cx, 1
	CMP cx, 0
	JNZ dItselfLoop

RET

dInAWall: ; dx contains head
	MOV bh, vHeight
	MOV bl, vWidth

	CMP dh, bh
	JZ dEndGame
	CMP dl, bl
	JZ dEndGame
	CMP dh, 00h
	JZ dEndGame
	CMP dl, 00h
	JZ dEndGame

RET

dEndGame:
	XOR eax, eax
	MOV al,	 vWidth
	SUB al, 0Ah
	MOV bl, 2
	DIV bl
	MOV dl, al
	MOV al, vHeight
	DIV bl
	MOV dh, al
	
	MOV ax, 01h		;Blue end message
	CALL SetTextColor

	CALL GotoXY
	MOV edx, offset vLoseMessage
	CALL WriteString
	
	MOV dh, vHeight
	ADD dh, 2
	XOR dl, dl

	CALL GotoXY

	MOV ax, 0Fh		;Back to regular white
	CALL SetTextColor

	xor ecx, ecx
	call ReadChar

	exit

main ENDP

END main