
constant OSBoxY($80)
constant OSTransEnable($82)
constant OSTransState($83)
constant OSSpawnIndex($84)
constant OSIconIndex($85)

sceneMap512_Init: {
   
   lda.b #$80
	sta.w REG_INIDISP

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
	
	initOAM()
	
	jsr f_initActors
	jsr initSPT
	jsr initSVT
	jsr initDMAT
	
	//LoadPAL(bgNC, 0, 512, 0)
	//LoadVRAM(bgNP00, $0000, $8000, 1)
	//LoadVRAM(bgNP01, $0000+$8000, bgNP01.size, 2)
	//LoadVRAM(bgNM, $D000, bgNM.size, 3)
	//;LoadPAL(OSFontP, 16, OSFontP.size, 0)
	//;LoadPAL(OSBG2C, 32, OSBG2C.size, 0)
	//;LoadPAL(OSDbgBGP, 0, OSDbgBGP.size, 0)
	//;LoadPAL(OSFontErrorP, 8, OSFontErrorP.size, 0)
	//;LoadPAL(OSFontSuccessP, $C, OSFontSuccessP.size, 0)
	//;LoadVRAM(OSFontData, $A000, $05A0, 0)
	//;LoadVRAM(OSDbgBGT, $4000, OSDbgBGT.size, 0)
	//;LoadVRAM(OSDbgBGM, $6000, OSDbgBGM.size, 0)
	//;LoadVRAM(OSBG2P, $C000, OSBG2P.size, 0)
	//;LoadVRAM(OSBG2M, $E000, OSBG2M.size, 0)

	LoadPAL(bgGardenC+2, 0, 16*2, 0)
	LoadPAL(bgWaterMeterC, 16, 4*2, 0)
	LoadVRAM(bgGardenP, $4000, bgGardenP.size, 1)
	LoadVRAM(bgGardenM, $5000, bgGardenM.size, 3)
	LoadVRAM(bgWaterMeterP, $6000, bgGardenP.size, 1)
	
	setBGModeN(1)

	//;setBGMap(1, $D000, MAP_64x64)
	//;setBGMap(2, $E000, MAP_64x64)
	//;setBGMap(3, $8000, MAP_64x32)
	//;setBG34Tile($A000, $0000)
	//;setBG12Tile($0000, $C000)

	setBGMap(1, $5000, MAP_32x32)
	setBGMap(3, $7000, MAP_64x64)
	setBG12Tile($4000, $C000)
	setBG34Tile($6000, $0000)

	initMeter(2, $7000, $10, 14, 1, 0)
	initMeter(2, $7000, $10, 14, 1, 1)

	lda.b #2
	sta.b $60
	lda.b #14
	sta.b $61
	lda.b #0
	sta.b $62

	lda.b #marioActor_Init >> 16
	ldx.w #marioActor_Init
	ldy.w #$5550
	jsr createActorDirect

	lda.b #%00010101
	sta.w REG_TM


	lda.b #%00000000 // 8x8 -> 16x16
	sta.w REG_OBSEL

	lda.b #$0F
	sta.b $64
	sta.w REG_BG3VOFS

	ldx.w #sceneMap512_update
	stx.w scenePtr

	FadeIN()

	rts

}

sceneMap512_update:

	ReadPad({JOY_START})
	beq +

	lda.b gameFrame
	and.b #7
	bne +

	jsr sceneMap512_spawn

	+

	drawMeterHalf($60, $7000, $10, 1, $61, $62)
	drawMeterBottom($60, $7000, $10, 1, $61, $62)

	lda.b $64
	sta.w REG_BG3VOFS
	lda.b $65
	sta.w REG_BG3VOFS

	rts

sceneMap512_spawn:

	lda.b #coinActor_Init >> 16
	ldx.w #coinActor_Init
	ldy.w #$5555
	jsr spawnActor

	lda.b #$0A
	sta.w $2143
	lda.b #$04
	sta.w $2141
	lda.b #$80
	sta.w $2142
	lda.b #$08
	sta.w $2140


	rts

//; $60 - meter frame
//; $61-62 - meter X position
//; $63 - meter timer
//; $64-65 - meter Y position
//; $66 - is meter empty?
sceneMap512_DecreaseWater:

	lda.b $66
	bne ++
	
	lda.b $63
	cmp.b #4
	bne +

	stz.b $63
	inc.b $60
	inc.b $60

	lda.b $60
	cmp.b #$14
	bne +

	lda.b #2
	sta.b $60
	dec.b $61

	+
	inc.b $63
	jsr sceneMap512_checkWaterEmpty
	+
	rts

sceneMap512_checkWaterEmpty:

	ldx.b $60
	cpx.w #$0112
	bne +

	lda.b #1
	sta.b $66

	+
	rts

grad:
db $02,$00,$00,$AD,$08,$09,$00,$00,$AE,$08,$0C,$00,$00,$AF,$08
db $08,$00,$00,$CF,$08,$01,$00,$00,$AF,$08,$03,$00,$00,$D0,$08
db $0B,$00,$00,$D1,$08,$0B,$00,$00,$D2,$08,$07,$00,$00,$F2,$08
db $01,$00,$00,$D2,$08,$03,$00,$00,$F3,$08,$0C,$00,$00,$F4,$08
db $0D,$00,$00,$F5,$08,$03,$00,$00,$15,$09,$01,$00,$00,$F5,$08
db $02,$00,$00,$15,$09,$06,$00,$00,$16,$09,$05,$00,$00,$16,$0D
db $01,$00,$00,$16,$09,$05,$00,$00,$17,$09,$0C,$00,$00,$18,$09
db $01,$00,$00,$38,$09,$01,$00,$00,$18,$09,$02,$00,$00,$38,$09
db $07,$00,$00,$39,$09,$0B,$00,$00,$3A,$09,$0B,$00,$00,$5B,$09
db $01,$00,$00,$3A,$09,$01,$00,$00,$3B,$09,$01,$00,$00,$5B,$09
db $09,$00,$00,$5C,$09,$0C,$00,$00,$5D,$09,$09,$00,$00,$7D,$09
db $01,$00,$00,$5D,$09,$02,$00,$00,$7D,$09,$01,$00,$00,$7E,$09
db $0C,$00,$00,$7F,$09,$0E,$00,$00,$7F,$09
db $00