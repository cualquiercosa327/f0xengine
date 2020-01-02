sceneNull02_Init: {
	
	
	lda.b #$80
	sta.w REG_INIDISP
	
	initOAM()
	
	jsr f_initActors
	jsr initSPT
	jsr initSVT
	
	LoadPAL(bgStarP, 0, 32, 1)
	
	LoadVRAM(bgStarT, $6000, bgStarT.size, 1)
	LoadVRAM(bgStarM, $4000, bgStarM.size, 1)
	
	lda.b #%00001001
	sta.w REG_BGMODE

	setBGMap(1, $4000)
	setBGMap(2, $8000)
	setBG12Tile($6000, $A000)

	lda.b #%00010011
	sta.w REG_TM 

	stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos Low Byte
	stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos High Byte
	stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Scroll Pos Low Byte
	stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Pos High Byte
	
	stz.w REG_BG2HOFS // Store Zero To BG1 Horizontal Scroll Pos Low Byte
	stz.w REG_BG2HOFS // Store Zero To BG1 Horizontal Scroll Pos High Byte
	
	lda.b #6
	sta.w REG_BG2VOFS // Store Zero To BG1 Vertical Scroll Pos Low Byte
	stz.w REG_BG2VOFS // Store Zero To BG1 Vertical Pos High Byte

	lda.b #%00000000 // 8x8 -> 16x16
	sta.w REG_OBSEL
	
	ldx.w #sceneNull02_Update
	stx.w scenePtr
	
	FadeIN()
	
	lda.b #$C1
	sta.w $2141
	
	rts

}


sceneNull02_Update: {

	rep #$30
	
	lda.b $70
	cmp.w #100
	beq +
	
	clc
	adc.w #1
	sta.b $70
	
	sep #$20
	
	rts
	
	+
	sep #$20
	
	FadeOUT()
	
	ldx.w #sceneMap512_Init
	stx.w scenePtr
	
	lda.b #0
	sta.w REG_BG2VOFS
	
	lda.b #$80
	sta.w REG_INIDISP
	
	
	rts
}

sceneNull02_MenuInit: {

	stz.b $70
	
	setHDMAColor(colorTable, 3, 0, 2)
	
	LoadPAL(bgAnalMenuP, 0, 32, 6)
	LoadPAL(bgHandP, 16, 32, 6)
	
	LoadVRAM(bgAnalMenuT, $6000, bgAnalMenuT.size, 6)
	LoadVRAM(bgAnalMenuM, $4000, bgAnalMenuM.size, 6)
	LoadVRAM(bgHandT, $A000, bgHandT.size, 6)
	LoadVRAM(bgHandM, $8000, bgHandM.size, 6)
	
	ldx.w #sceneNull02_MenuUpdate
	stx.w scenePtr
	
	
	FadeIN()
	
	rts

}

sceneNull02_MenuUpdate: {
	
	lda.b $70			//; adc/sbc cursor pos by 0x14 when moving
	sta.w REG_BG2VOFS
	stz.w REG_BG2VOFS
	
	lda.b $73
	tax
	lda.w cursorSine,x
	sec
	sbc.b #$FF
	sta.w REG_BG2HOFS
	stz.w REG_BG2HOFS
	
	inc $73
	
	lda.b $73
	cmp.b #$20
	bcc +
	stz.b $73
	+
	jsr sceneNull02_inputTime
	jsr sceneNull02_inputHandle
	jsr sceneNull02_choiceHandle

	rts
}


sceneNull02_inputTime: {
	
	lda.b $6A
	cmp #$A0
	beq +
	rts
	+
	lda.b #$9F
	sta.b $6A
	rts

}

sceneNull02_inputHandle: 

	lda.w REG_JOY1H
	sta.b $69 		//; input
	
	lda.w $69
	cmp.b #$00
	bne +
	lda.b #$00
	sta.b $6A
	rts
	
	+ {
		inc $6A
		rts
	}
	
sceneNull02_choiceHandle:

	lda.b $6A
	cmp.b #$01
	bne +
	lda.b $69
	lsr
	tax
	jmp (inputLUT,x)
	+
	rts

inputLUT:
	dw SN02_null
	dw SN02_MoveDown
	dw SN02_MoveUp
	dw $FFFF
	dw SN02_Start
	
SN02_MoveDown: {

	lda.b $70
	sec
	sbc.b #$14
	sta.b $70
	
	stz.w $2141
	
	lda.b #9
	jsr playSFX
	
	rts
}

SN02_MoveUp: {

	lda.b $70
	clc
	adc.b #$14
	sta.b $70
	
	lda.b #9
	jsr playSFX
	
	rts
}

SN02_Start: {
	
	lda.b #$0F
	jsr playSFX
	
	lda.b #$03
	sta.w $74
	sta.w REG_MOSAIC
	stz.w $75
	
	lda.b #$0F
	sta.w $76
	
	ldx.w #SN02_exitUpdate
	stx.w scenePtr
	
	rts
}

SN02_null:

	rts
	

SN02_exitUpdate:

	jsr SN02_transMosaic
	
	rts
	
SN02_transMosaic: {
	
	lda.b $74
	cmp #$F3
	beq ++
	
	lda.w $75
	cmp #$01
	bmi +
	
	lda.w $74
	and #$F0
	lsr #$04
	inc
	asl #$04
	ora #$03
	sta.w REG_MOSAIC
	sta.w $74
	stz.w $75
	
	lda.b $76
	dec
	sta.w REG_INIDISP
	sta.b $76
	
	rts
	
	+
	inc $75
	rts
	
	+
	
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	WaitNMI()
	
	lda.b #$80
	sta.w REG_INIDISP
	
	stz.w REG_HDMAEN  
	
	LoadPAL(bgTestMapP, 0, 32, 0)
	LoadVRAM(bgTestMapT, $6000, bgTestMapT.size, 0)
	LoadVRAM(bgTestMapM, $4000, $2000, 0)

	setBGMode(1)

	setBGMap(1, $4000)
	setBG12Tile($6000, 0)

	stz.w REG_MOSAIC

	lda.b #%00010001
	sta.w REG_TM
	
	FadeIN()
	
	ldx.w #AT_Init
	stx.w scenePtr
	
	rts
}

AT_Init:

	ldx.w #ballAct
	lda.b #ballAct >> 16
	jsr createActor
	
	ldx.w #AT_Update
	stx.w scenePtr
	
	rts
	
AT_Update:

	rts