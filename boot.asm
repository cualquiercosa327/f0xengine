mainBoot:

//; Load boot palette to position 0 in CGRAM, boot tilemap at location 0 of VRAM, and boot tiles to location $2000
LoadPAL(bgBootP, 0, bgBootP.size, 0)
UpdateVRAM(bgBootM, $0000, bgBootM.size, 0)
UpdateVRAM(bgBootT, $2000, bgBootT.size, 0)

//; Set Mode 3, Priority 1, 8x8 tiles
lda.b #%00001011 
sta.w REG_BGMODE

// Setup BG1 4 Color Background
lda.b #%00000000  // AAAAAASS: S = BG Map Size, A = BG Map Address
sta.w REG_BG1SC   // $2108: BG1 32x32, BG1 Map Address = $3F (VRAM Address / $400)
lda.b #%00000001  // BBBBAAAA: A = BG1 Tile Address, B = BG2 Tile Address
sta.w REG_BG12NBA // $210B: BG1 Tile Address = $0 (VRAM Address / $1000)

lda.b #%00000001 // Enable BG1
sta.w REG_TM // $212C: BG1 To Main Screen Designation

stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Position Lo Byte
stz.w REG_BG1HOFS // Store Zero To BG1 Horizontal Scroll Position Hi Byte

ldx.w #0
-
	lda XBAND_PC_ID,x
	sta $80,x
	inx
	cpx #4
	bne -
	
lda.b #0
ldx.w #sa_main
jsr f_initSA1

FadeIN()

lda.b #$50
bootLoop:
	WaitNMI()
	dec
	bne bootLoop
	
FadeOUT()
lda.b #$80
sta.w REG_INIDISP // $80: Turn Off Screen, Zero Brightness ($2100)