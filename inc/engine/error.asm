
//; Something broke
//; alert the shit

break_exception: {

	//; preserve the processor state 
	phb
	phd
	rep #$30
	pha
	phx
	phy
	//; these contents should now be on the stack:
	//; Y (16), X (16), A (16), DP (16), DB (8), SR (8), PC (16), PB (8)

	sep #$20
	
	lda.b #$80
	sta.w REG_INIDISP		//; shut off screen
	
	ClearVRAM(null, $0000, $7FFF, 2)
	ClearVRAM(null, $8000, $7FFF, 2)
	LoadPAL(OSFontP, 16, OSFontP.size, 0)
	LoadPAL(OSDbgBGP, 0, OSDbgBGP.size, 0)
	LoadPAL(OSFontErrorP, 8, OSFontErrorP.size, 0)
	LoadPAL(OSFontSuccessP, $C, OSFontSuccessP.size, 0)
	LoadVRAM(OSFontData, $A000, $05A0, 0)
	LoadVRAM(OSDbgBGT, $4000, OSDbgBGT.size, 0)
	LoadVRAM(OSDbgBGM, $6000, OSDbgBGM.size, 0)
	
	setBGModeN(1)

	setBGMap(1, $6000, MAP_64x64)
	setBGMap(3, $8000, MAP_64x32)
	setBG34Tile($A000, $0000)
	setBG12Tile($4000, $0000)

	lda.b #%00000101
	sta.w REG_TM 

	stz.w REG_BG3HOFS // Store Zero To BG1 Horizontal Scroll Pos Low Byte
	stz.w REG_BG3HOFS // Store Zero To BG1 Horizontal Scroll Pos High Byte
	stz.w REG_BG3VOFS // Store Zero To BG1 Vertical Scroll Pos Low Byte
	stz.w REG_BG3VOFS // Store Zero To BG1 Vertical Pos High Byte
	stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos Low Byte
	stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos High Byte
	stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Scroll Pos Low Byte
	stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Pos High Byte


	lda.b #%00000000 // 8x8 -> 16x16
	sta.w REG_OBSEL
	
	//; ...

	print("-- OOPS CATCHER V1.0 --", $8000, $10, 4,4)
	print("BRK ERROR !!!", $8000, $8, 10,5)
	
	print("A = ", $8000, $8, 4,8)
	print("X = ", $8000, $8, 4,9)
	print("Y = ", $8000, $8, 4,10)

	print("DP = ", $8000, $8, 16,8)
	print("DB = ", $8000, $8, 16,9)
	print("PB = ", $8000, $8, 16,10)

	print("PC = ", $8000, $8, 9,12)
	print("SR = ", $8000, $8, 9,13)

	ply
	sty.b $00
	printValue($00, $8000, 2, $8, 8,10)		//; print Y
	
	plx
	stx.b $00
	printValue($00, $8000, 2, $8, 8,9)		//; print X

	ply
	sty.b $00
	printValue($00, $8000, 2, $8, 8,8)		//; print A

	ply
	sty.b $00
	printValue($00, $8000, 2, $8, 21,8)		//; print DP

	pla
	sta.b $00
	printValue($00, $8000, 1, $8, 21,9)		//; print DB

	pla
	sta.b $00
	printValue($00, $8000, 1, $8, 14,13)	//; print SR

	lda.b $00
	bit.b #$80		//; check N (negative)
	beq +
	print("N", $8000, $8, 18,13)
	bra ++
	+
	print("-", $8000, $8, 18,13)
	
	+
	lda.b $00
	bit.b #$40		//; check V (overflow)
	beq +
	print("V", $8000, $8, 19,13)
	bra ++
	+
	print("-", $8000, $8, 19,13)
	
	+

	lda.b $00
	bit.b #$20		//; check M (accumulator size)
	beq +
	print("M", $8000, $8, 20,13)
	bra ++
	+
	print("-", $8000, $8, 20,13)
	
	+

	lda.b $00
	bit.b #$10		//; check X (index size)
	beq +
	print("X", $8000, $8, 21,13)
	bra ++
	+
	print("-", $8000, $8, 21,13)
	
	+

	lda.b $00
	bit.b #$08		//; check D (decimal)
	beq +
	print("D", $8000, $8, 22,13)
	bra ++
	+
	print("-", $8000, $8, 22,13)
	
	+

	lda.b $00
	bit.b #$04		//; check I (IRQ disable)
	beq +
	print("I", $8000, $8, 23,13)
	bra ++
	+
	print("-", $8000, $8, 23,13)
	
	+

	lda.b $00
	bit.b #$02		//; check Z (zero)
	beq +
	print("Z", $8000, $8, 24,13)
	bra ++
	+
	print("-", $8000, $8, 24,13)
	
	+

	lda.b $00
	bit.b #$01		//; check C (carry)
	beq +
	print("C", $8000, $8, 25,13)
	bra ++
	+
	print("-", $8000, $8, 25,13)
	
	+

	ply
	sty.b $00
	pla
	sta.b $02
	printValue($00, $8000, 3, $8, 14,12)		//; print PC

	printValue($02, $8000, 1, $8, 21,10)		//; print PB
	
	lda.b #$0F
	sta.w REG_INIDISP

	WaitNMI()
	
	loop:
	jmp loop
}