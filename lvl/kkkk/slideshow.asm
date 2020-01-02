scene_slideShow1Init:

    lda.b #$80
	sta.w REG_INIDISP

    initOAM()
	
	jsr f_initActors
	jsr initSPT
	jsr initSVT

	LoadPAL(bgKKKK1C, 0, bgKKKK1C.size, 0)
	LoadVRAM(bgKKKK1P, $0000, bgKKKK1P.size, 1)
	LoadVRAM(bgKKKK1M, $A000, bgKKKK1M.size, 1)
	
	setBGModeN(3)

	setBGMap(1, $A000, MAP_32x32)
	setBG12Tile($0000, $0000)

	lda.b #%00000001
	sta.w REG_TM 

	stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos Low Byte
	stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Pos High Byte
	stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Scroll Pos Low Byte
	stz.w REG_BG1VOFS // Store Zero To BG1 Vertical Pos High Byte

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow2Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow2Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    jsr sceneSlideShow_wait
    
    LoadPAL(bgKKKK2C, 0, bgKKKK2C.size, 0)
	LoadVRAM(bgKKKK2P, $0000, bgKKKK2P.size, 1)
	LoadVRAM(bgKKKK2M, $A000, bgKKKK2M.size, 1)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow3Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow3Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    jsr sceneSlideShow_wait

    setBGMap(1, $A000, MAP_32x32)
    
    setCGRAM(bgKKKK3C, 0, bgKKKK3C.size)
    setVRAM(bgKKKK3P, $0000, $8000)
    setVRAM(bgKKKK3_2P, $8000, bgKKKK3_2P.size)
    setVRAM(bgKKKK3M, $A000, bgKKKK3M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow4Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow4Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    jsr sceneSlideShow_wait
    
    setCGRAM(bgKKKK4C, 0, bgKKKK4C.size)
    setVRAM(bgKKKK4P, $0000, $8000)
    setVRAM(bgKKKK4_2P, $8000, bgKKKK4_2P.size)
    setVRAM(bgKKKK4M, $A000, bgKKKK4M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow5Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow5Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    jsr sceneSlideShow_wait
    
    setCGRAM(bgKKKK5C, 0, bgKKKK5C.size)
    setVRAM(bgKKKK5P, $0000, $8000)
    setVRAM(bgKKKK5_2P, $8000, bgKKKK5_2P.size)
    setVRAM(bgKKKK5M, $A000, bgKKKK5M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow6Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow6Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    jsr sceneSlideShow_wait
    
    setCGRAM(bgKKKK6C, 0, bgKKKK6C.size)
    setVRAM(bgKKKK6P, $0000, $8000)
    setVRAM(bgKKKK6_2P, $8000, bgKKKK6_2P.size)
    setVRAM(bgKKKK6M, $A000, bgKKKK6M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow7Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow7Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    jsr sceneSlideShow_wait
    
    setCGRAM(bgKKKK7C, 0, bgKKKK7C.size)
    setVRAM(bgKKKK7P, $0000, $8000)
    setVRAM(bgKKKK7_2P, $8000, bgKKKK7_2P.size)
    setVRAM(bgKKKK7M, $A000, bgKKKK7M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow8Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow8Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    jsr sceneSlideShow_wait
    
    setCGRAM(bgKKKK8C, 0, bgKKKK8C.size)
    setVRAM(bgKKKK8P, $0000, $8000)
    setVRAM(bgKKKK8_2P, $8000, bgKKKK8_2P.size)
    setVRAM(bgKKKK8M, $A000, bgKKKK8M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow9Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow9Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    jsr sceneSlideShow_wait
    
    setCGRAM(bgKKKK9C, 0, bgKKKK9C.size)
    setVRAM(bgKKKK9P, $0000, $8000)
    setVRAM(bgKKKK9_2P, $8000, bgKKKK9_2P.size)
    setVRAM(bgKKKK9M, $A000, bgKKKK9M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow10Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow10Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    jsr sceneSlideShow_wait
    
    setCGRAM(bgKKKK10C, 0, bgKKKK10C.size)
    setVRAM(bgKKKK10P, $0000, $8000)
    setVRAM(bgKKKK10_2P, $8000, bgKKKK10_2P.size)
    setVRAM(bgKKKK10M, $A000, bgKKKK10M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow11Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow11Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    jsr sceneSlideShow_wait
    
    setCGRAM(bgKKKK11C, 0, bgKKKK11C.size)
    setVRAM(bgKKKK11P, $0000, $8000)
    setVRAM(bgKKKK11_2P, $8000, bgKKKK11_2P.size)
    setVRAM(bgKKKK11M, $A000, bgKKKK11M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow12Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow12Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    setBGModeN(3)

    jsr sceneSlideShow_wait
    
    setCGRAM(bgKKKK12C, 0, bgKKKK12C.size)
    setVRAM(bgKKKK12P, $0000, $8000)
    setVRAM(bgKKKK12_2P, $8000, bgKKKK12_2P.size)
    setVRAM(bgKKKK12M, $A000, bgKKKK12M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow13Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShow13Init:
    
    lda.b #$80
    sta.w REG_INIDISP

    setBGModeN(1)

    jsr sceneSlideShow_wait
    
    ClearVRAM(null, $0000, $7FFF, 1)
    ClearVRAM(null, $8000, $7FFF, 1)
    setCGRAM(bgKKKK13C, 0, bgKKKK13C.size)
    setVRAM(bgKKKK13P, $0000, $8000)
    setVRAM(bgKKKK13M, $A000, bgKKKK13M.size)

    ldx.w #scene_slideShow1Run
	stx.w scenePtr

    stz.b $60

    ldx.w #scene_slideShow13Init
    stx.w $62

    FadeINDelay()
    
    rts

scene_slideShowCreditsInit:

    lda.b #$80
    sta.w REG_INIDISP

    setBGModeN(3)
    setCGRAM(bgKKKKCreditsC, 0, bgKKKKCreditsC.size)
    setVRAM(bgKKKKCreditsP, $0000, $8000)
    setVRAM(bgKKKKCreditsM, $A000, bgKKKKCreditsM.size)

    lda.b #2
    sta.w $2140

    ldx.w #scene_slideShowCreditsRun
    stx.b scenePtr

    FadeINDelay()

    rts

scene_slideShowCreditsRun:

    rts

scene_slideShow1Run:

    jsr sceneSlideShow_readA
    jsr sceneSlideShow_readB
    jsr sceneSlideShow_readY
    jsr sceneSlideShow_readSecret

    rts

sceneSlideShow_readA:

    ReadJOY(REG_JOY1L, %10000000)
    beq ++

    lda.b $60
    bne ++

    lda.b $64
    cmp.b #12
    bne +
    
    rts
    
    +
    inc $60
    inc $64

    lda.b #1
    sta.w $2140

    FadeOUT()

    ldx.b $62
    stx.w scenePtr

    +
    rts

sceneSlideShow_readB:

    ReadJOY(REG_JOY1H, %10000000)
    beq ++

    lda.b $60
    bne ++

    lda.b $64
    bne +

    rts

    +
    inc $60
    dec $64

    lda.b #1
    sta.w $2140

    FadeOUT()

    lda.b #$80
    sta.w REG_INIDISP
    jsr sceneSlideShow_wait
    
    _jumpBackToSlide:
    rep #$20
    lda.b $64
    and.w #$FF
    asl
    tax
    lda.w sceneSlideShowPtrs,x
    sta.b scenePtr
    sta.b $62
    and.w #$FF
    sep #$20

    +
    rts

sceneSlideShow_readY:

    ReadJOY(REG_JOY1H, %01000000)
    beq +

    lda.b $60
    bne +

    inc $60

    lda.b #12
    sta.b $64

    lda.b #1
    sta.w $2140

    FadeOUT()

    lda.b #$80
    sta.w REG_INIDISP
    jsr sceneSlideShow_wait

    rep #$20
    lda.b $64
    and.w #$FF
    asl
    tax
    lda.w sceneSlideShowPtrs,x
    sta.b scenePtr
    sta.b $62
    and.w #$FF
    sep #$20

    +
    rts

sceneSlideShow_readSecret:

    //; read L and R
    ReadJOY(REG_JOY1L, %00100000)
    beq +
    ReadJOY(REG_JOY1L, %00010000)
    beq +
    //; read Right and Start
    ReadJOY(REG_JOY1H, %00000001)
    beq +
    ReadJOY(REG_JOY1H, %00010000)
    beq +

    lda.b #13
    sta.b $64
    rep #$20
    lda.b $64
    and.w #$FF
    asl
    tax
    lda.w sceneSlideShowPtrs,x
    sta.b scenePtr
    sta.b $62
    and.w #$FF
    sep #$20
    +
    rts

sceneSlideShow_wait:

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

    rts

sceneSlideShowPtrs:

    dw scene_slideShow1Init
    dw scene_slideShow2Init
    dw scene_slideShow3Init
    dw scene_slideShow4Init
    dw scene_slideShow5Init
    dw scene_slideShow6Init
    dw scene_slideShow7Init
    dw scene_slideShow8Init
    dw scene_slideShow9Init
    dw scene_slideShow10Init
    dw scene_slideShow11Init
    dw scene_slideShow12Init
    dw scene_slideShow13Init
    dw scene_slideShowCreditsInit

//; slideshow banks
seek($98000)
insert bgKKKK1P, "bg/kkkk/kkkk_1.pic"
insert bgKKKK1M, "bg/kkkk/kkkk_1.map"
insert bgKKKK1C, "bg/kkkk/kkkk_1.clr"
seek($A8000)
insert bgKKKK2P, "bg/kkkk/kkkk_2.pic"
insert bgKKKK2M, "bg/kkkk/kkkk_2.map"
insert bgKKKK2C, "bg/kkkk/kkkk_2.clr"
seek($B8000)
insert bgKKKK3P, "bg/kkkk/kkkk_3_1.pic"
seek($C8000)
insert bgKKKK3_2P, "bg/kkkk/kkkk_3_2.pic"
insert bgKKKK3M, "bg/kkkk/kkkk_3.map"
insert bgKKKK3C, "bg/kkkk/kkkk_3.clr"
seek($D8000)
insert bgKKKK4P, "bg/kkkk/kkkk_4_1.pic"
seek($E8000)
insert bgKKKK4_2P, "bg/kkkk/kkkk_4_2.pic"
insert bgKKKK4M, "bg/kkkk/kkkk_4.map"
insert bgKKKK4C, "bg/kkkk/kkkk_4.clr"
seek($F8000)
insert bgKKKK5P, "bg/kkkk/kkkk_5_1.pic"
seek($108000)
insert bgKKKK5_2P, "bg/kkkk/kkkk_5_2.pic"
insert bgKKKK5M, "bg/kkkk/kkkk_5.map"
insert bgKKKK5C, "bg/kkkk/kkkk_5.clr"
seek($118000)
insert bgKKKK6P, "bg/kkkk/kkkk_6_1.pic"
seek($128000)
insert bgKKKK6_2P, "bg/kkkk/kkkk_6_2.pic"
insert bgKKKK6M, "bg/kkkk/kkkk_6.map"
insert bgKKKK6C, "bg/kkkk/kkkk_6.clr"
seek($138000)
insert bgKKKK7P, "bg/kkkk/kkkk_7_1.pic"
seek($148000)
insert bgKKKK7_2P, "bg/kkkk/kkkk_7_2.pic"
insert bgKKKK7M, "bg/kkkk/kkkk_7.map"
insert bgKKKK7C, "bg/kkkk/kkkk_7.clr"
seek($158000)
insert bgKKKK8P, "bg/kkkk/kkkk_8_1.pic"
seek($168000)
insert bgKKKK8_2P, "bg/kkkk/kkkk_8_2.pic"
insert bgKKKK8M, "bg/kkkk/kkkk_8.map"
insert bgKKKK8C, "bg/kkkk/kkkk_8.clr"
seek($178000)
insert bgKKKK9P, "bg/kkkk/kkkk_9_1.pic"
seek($188000)
insert bgKKKK9_2P, "bg/kkkk/kkkk_9_2.pic"
insert bgKKKK9M, "bg/kkkk/kkkk_9.map"
insert bgKKKK9C, "bg/kkkk/kkkk_9.clr"
seek($198000)
insert bgKKKK10P, "bg/kkkk/kkkk_10_1.pic"
seek($1A8000)
insert bgKKKK10_2P, "bg/kkkk/kkkk_10_2.pic"
insert bgKKKK10M, "bg/kkkk/kkkk_10.map"
insert bgKKKK10C, "bg/kkkk/kkkk_10.clr"
seek($1B8000)
insert bgKKKK11P, "bg/kkkk/kkkk_11_1.pic"
seek($1C8000)
insert bgKKKK11_2P, "bg/kkkk/kkkk_11_2.pic"
insert bgKKKK11M, "bg/kkkk/kkkk_11.map"
insert bgKKKK11C, "bg/kkkk/kkkk_11.clr"
seek($1D8000)
insert bgKKKK12P, "bg/kkkk/kkkk_12_1.pic"
seek($1E8000)
insert bgKKKK12_2P, "bg/kkkk/kkkk_12_2.pic"
insert bgKKKK12M, "bg/kkkk/kkkk_12.map"
insert bgKKKK12C, "bg/kkkk/kkkk_12.clr"
seek($1F8000)
insert bgKKKK13P, "bg/kkkk/kkkk_13.pic"
insert bgKKKK13M, "bg/kkkk/kkkk_13.map"
insert bgKKKK13C, "bg/kkkk/kkkk_13.clr"
insert bgKKKKCreditsP, "bg/kkkk/kkkk_credits.pic"
insert bgKKKKCreditsM, "bg/kkkk/kkkk_credits.map"
insert bgKKKKCreditsC, "bg/kkkk/kkkk_credits.clr"
seek($208000)