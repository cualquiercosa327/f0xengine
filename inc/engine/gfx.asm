
constant DBG_TXT_LOC($F800)

constant BG1_OUTSIDE_BG2_INSIDE($0300 + $01)
constant OBJ_OUTSIDE_BG2_INSIDE($0300 + $10)

constant BG1_16x16(4)
constant BG2_16x16(5)
constant BG3_16x16(6)
constant BG4_16x16(7)

constant MAP_32x32(0)
constant MAP_64x32(1)
constant MAP_32x64(2)
constant MAP_64x64(3)

macro setBGMode(MODE) {
	
	lda.b #(1 << ({MODE})) | 8
	sta.w REG_BGMODE
}

macro setBGModeN(MODE) {
	
	lda.b #(({MODE})) | 8
	sta.w REG_BGMODE
}

macro setBGMode(MODE, SIZE) {
	
	lda.b #1 << ({MODE}-1) | (1 << ({SIZE}))
	sta.w REG_BGMODE
}

macro setBGMap(NUM, MAP) {

	lda.b #(({MAP} / $0400) << 1)
	sta.w REG_BG{NUM}SC
}

macro setBGMap(NUM, MAP, SIZE) {

	lda.b #(({MAP} / $0400) << 1) | {SIZE}
	sta.w REG_BG{NUM}SC
}

macro setBG12Tile(BG1T, BG2T) {

	lda.b #(({BG2T} / $2000) << 4) | ({BG1T} / $2000)
	sta.w REG_BG12NBA

}

macro setBG34Tile(BG3T, BG4T) {

	lda.b #(({BG4T} / $2000) << 4) | ({BG3T} / $2000)
	sta.w REG_BG34NBA

}

macro setVRAM(SRC, DEST, SIZE) {

  lda.b #$80
  sta.w REG_VMAIN

  ldx.w #{SRC}
  lda.b #{SRC} >> 16
  ldy.w #{DEST}
  stx.b DMASrc
  sta.b DMASrc+2
  sty.w DMADst
  ldx.w #{SIZE}
  stx.w DMASize

  jsr loadVRAM

}

macro setCGRAM(SRC, DEST, SIZE) {

  ldx.w #{SRC}
  lda.b #{SRC} >> 16
  ldy.w #{DEST}
  stx.b DMASrc
  sta.b DMASrc+2
  sty.w DMADst
  ldx.w #{SIZE}
  stx.w DMASize
  
  jsr loadPAL

}

loadVRAM:

  rep #$20
  lda.w DMADst
  lsr
  sta.w REG_VMADDL
  sep #$20

  lda.b #$01
  sta.w REG_DMAP1

  lda.b #$18
  sta.w REG_BBAD1

  ldx.w DMASrc
  stx.w REG_A1T1L

  lda.b DMASrc+2
  sta.w REG_A1B1   

  ldx.w DMASize
  stx.w REG_DAS1L 

  lda.b #$01 << 1
  sta.w REG_MDMAEN

  rts

loadPAL:

  lda.b DMADst   // Set CGRAM Destination
  sta.w REG_CGADD // $2121: CGRAM

  stz.w REG_DMAP1 // Set DMA Mode (Write Byte, Increment Source) ($43X0: DMA Control)
  lda.b #$22           // Set Destination Register ($2122: CGRAM Write)
  sta.w REG_BBAD1 // $43X1: DMA Destination
  ldx.w DMASrc         // Set Source Offset
  stx.w REG_A1T1L // $43X2: DMA Source
  lda.b DMASrc+2   // Set Source Bank
  sta.w REG_A1B1  // $43X4: Source Bank
  ldx.w DMASize        // Set Size In Bytes To DMA Transfer (2 Bytes For Each Color)
  stx.w REG_DAS1L // $43X5: DMA Transfer Size/HDMA

  lda.b #$01 << 1 // Start DMA Transfer On Channel
  sta.w REG_MDMAEN     // $420B: DMA Enable

  rts

macro print(SRC, DEST, COLOR, X, Y) {
  
  bra {#}printStart
	
  {#}sourceBefore:
  db {SRC}
  {#}printSize:
  db {#}printSize-{#}sourceBefore
  
  
  {#}printStart:
  lda.b #0
  xba
  lda.l {#}printSize
  tay
	lda.b #$80
  sta.w REG_VMAIN
  ldx.w #({DEST} + (({Y} * 64) + ({X} * 2)) >> 1)
  stx.w REG_VMADDL

  ldx.w #0 
  {#}LoopText:
	lda.l {#}sourceBefore,x

    sta.w REG_VMDATAL
		lda.b #{COLOR} | $20
		sta.w REG_VMDATAH
    inx
    dey
    cpy.w #0
    bne {#}LoopText 
}

macro initMeter(SRC, DEST, COLOR, SIZE, X, Y) {

  lda.b #0
  xba
  lda.b #{SIZE}
  tay
	lda.b #$80
  sta.w REG_VMAIN
  ldx.w #({DEST} + (({Y} * 64) + ({X} * 2)) >> 1)
  stx.w REG_VMADDL

  ldx.w #0 
  {#}LoopText:
	lda.b #{SRC}
    sta.w REG_VMDATAL
		lda.b #{COLOR} | $20
		sta.w REG_VMDATAH
    inx
    dey
    cpy.w #0
    bne {#}LoopText 
}

macro drawMeterHalf(SRC, DEST, COLOR, SIZE, X, Y) {

  tdc
  lda.b #{SIZE}
  tay
	lda.b #$80
  sta.w REG_VMAIN
  lda.b {Y}
  ldx.w #64
  mulu(a,x,x)   //; {Y} * 64
  phx
  lda.b {X}
  ldx.w #2
  mulu(a,x,a)   //; {X} * 2
  rep #$30
  clc
  adc $00,s     //; ({Y} * 64) + ({X} * 2)
  adc.w #{DEST} //; {DEST} + (({Y} * 64) + ({X} * 2)
  lsr           //; ({DEST} + (({Y} * 64) + ({X} * 2)) >> 1
  sta.w REG_VMADDL
  sep #$20
  plx

  ldx.w #0 
  {#}LoopText:
	lda.l {SRC},x
    sta.w REG_VMDATAL
		lda.b #{COLOR} | $20
		sta.w REG_VMDATAH
    inx
    dey
    cpy.w #0
    bne {#}LoopText 
}

macro drawMeterBottom(SRC, DEST, COLOR, SIZE, X, Y) {

  tdc
  lda.b #{SIZE}
  tay
	lda.b #$80
  sta.w REG_VMAIN
  lda.b {Y}
  inc
  ldx.w #64
  mulu(a,x,x)   //; {Y} * 64
  phx
  lda.b {X}
  ldx.w #2
  mulu(a,x,a)   //; {X} * 2
  rep #$30
  clc
  adc $01,s     //; ({Y} * 64) + ({X} * 2)
  adc.w #{DEST} //; {DEST} + (({Y} * 64) + ({X} * 2)
  lsr           //; ({DEST} + (({Y} * 64) + ({X} * 2)) >> 1
  sta.w REG_VMADDL
  sep #$20
  plx

  ldx.w #0 
  {#}LoopText:
	lda.l {SRC},x
    sta.w REG_VMDATAL
		lda.b #{COLOR} | $20
		sta.w REG_VMDATAH
    inx
    dey
    cpy.w #0
    bne {#}LoopText 
}

macro printRAM(SRC, DEST, COLOR, SIZE, X, Y) {

  lda.b #0
  xba
  lda.b #{SIZE}
  tay
	lda.b #$80
  sta.w REG_VMAIN
  ldx.w #({DEST} + (({Y} * 64) + ({X} * 2)) >> 1)
  stx.w REG_VMADDL

  ldx.w #0 
  {#}LoopText:
	lda.l {SRC},x
    sta.w REG_VMDATAL
		lda.b #{COLOR} | $20
		sta.w REG_VMDATAH
    inx
    dey
    cpy.w #0
    bne {#}LoopText 
}

macro printValue(SRC, DEST, SIZE, COLOR, X, Y) {
  
  lda.b #$80
  sta.w REG_VMAIN
  ldx.w #({DEST} + (({Y} * 64) + ({X} * 2)) >> 1)
  stx.w REG_VMADDL  

  ldx.w #{SIZE} //;  X = Number Of Hex Characters To Print

  {#}LoopHEX:
    dex //;  X--
    ldy.w #0002 //;  Y = 2 (Char Count)

    lda.w {SRC},x //;  A = Result Data
    lsr //;  A >>= 4
    lsr
    lsr
    lsr //;  A = Result Hi Nibble

    {#}LoopChar:
      cmp.b #10 //;  Compare Hi Nibble To 9
      clc //;  Clear Carry Flag
      bpl {#}HexLetter
      adc.b #$30 //;  Add Hi Nibble To ASCII Numbers
      sta.w REG_VMDATAL //;  Store Text To VRAM Lo Byte
	  lda.b #{COLOR} | $20
	  sta.w REG_VMDATAH
      bra {#}HexEnd
      {#}HexLetter:
      adc.b #$37 //;  Add Hi Nibble To ASCII Letters
      sta.w REG_VMDATAL //;  Store Text To VRAM Lo Byte
	  lda.b #{COLOR} | $20
	  sta.w REG_VMDATAH
      {#}HexEnd:
  
      lda.w {SRC},x //;  A = Result Data
      and.b #$F //;  A = Result Lo Nibble
      dey //;  Y--
      bne {#}LoopChar //;  IF (Char Count != 0) Loop Char

    cpx.w #0 //;  Compare X To 0
    bne {#}LoopHEX //;  IF (X != 0) Loop Hex Characters
}

//; ; 1FD0 = X
//; ; 1FD1 = Y
//; ; 1FD2 = SRC
//; ; 1FD4 = DST
//; ; 1FD6 = SIZE
f_print: {
	
	rep #$30
	
	lda.w $1FD1
	and.w #$FF
	asl #6
	sta.w sprCallback
	lda.w $1FD0
	and.w #$FF
	asl
	adc.w sprCallback
	adc.w $1FD4
	lsr
	tax
  
	lda.w #0
	sep #$20
	
	lda.b #$02
	sta.b tempLong+2
	lda.w $1FD2
	sta.b tempLong
	lda.w $1FD3
	sta.b tempLong+1
  
	stz.w REG_VMAIN 
	stx.w REG_VMADDL
	
	ldx.w #0
	print_loop:
		lda [tempLong]
		sta.w REG_VMDATAL
		//; lda.b #$04
		//; sta.w REG_VMDATAH
		inc tempLong
		inx
		cpx.w $1FD6
    bne print_loop

  rts

}

f_print_ram: {
	
	rep #$30
	
	lda.w $1FD1
	and.w #$FF
	asl #6
	sta.w sprCallback
	lda.w $1FD0
	and.w #$FF
	asl
	adc.w sprCallback
	adc.w $1FD4
	lsr
	tax
  
	lda.w #0
	sep #$20
	
	lda.b #$1E
	sta.b tempLong+2
	lda.w $1FD2
	sta.b tempLong
	lda.w $1FD3
	sta.b tempLong+1
  
	stz.w REG_VMAIN 
	stx.w REG_VMADDL
	
	ldx.w #0
	print_loop_r:
		lda [tempLong]
		sta.w REG_VMDATAL
		//; lda.b #$04
		//; sta.w REG_VMDATAH
		inc tempLong
		inx
		cpx.w $1FD6
    bne print_loop_r

  rts

}

//; ; Push in order (16-bit):
//; ; SRC addr
//; ; X + Y
f_printByte: {
  
  sta.w $0100
  stz.w REG_VMAIN
  
  rep #$30
  
  lda $03,s
  pha
  and.w #$FF
  asl #6
  sta.w tempWord
  pla
  xba
  and.w #$FF
  asl
  adc.w tempWord
  adc.w #DBG_TXT_LOC
  lsr
  sta.w REG_VMADDL
  and.w #$FF
  
  sep #$20
  
  ldy.w #0
  lda ($05,s),y
  pha
  pha
  lsr #4
  
  hexLoop:
  
  cmp.b #10 
  clc
  bpl hexL
  adc.b #$30
  sta.w REG_VMDATAL
  bra hexEnd
  
  hexL:
	
	adc.b #$37
	sta.w REG_VMDATAL
  
  hexEnd:
  
    iny
	pla
    and.b #$F
	cpy.w #$02
	bne hexLoop
  
  //; ; fix our stack
  plx
  stx.w tempWord
  plx
  plx
  pei (tempWord)
 
  rts
}

//; ; A (16) = Flags
//; ; X = X1 clip
//; ; Y = X2 clip

setWH01Window: {
  
  sep #$10		//; ; 8-bit index
  
  stx.w REG_WH0 //; ; X1 clip
  sty.w REG_WH1	//; ; x2 clip
  
  
  sep #$20			//; ; 8-bit accum
  rep #$10 			//; ; 16-bit index
  sta.w REG_TMW
  xba
  sta.w REG_WOBJSEL //; ; $2123: Window BG1/BG2 Mask
  rep #$30
  lda.w #0
  sep #$20
  
  rts

}

BGAProcess:

macro defineBGAFrame(TILE_PTR, MAP_PTR, PAL_PTR) {

	dl {TILE_PTR}
	dw {TILE_PTR}.size

	dl {MAP_PTR}
	dw {MAP_PTR}.size

	dl {PAL_PTR}
	dw {PAL_PTR}.size
}