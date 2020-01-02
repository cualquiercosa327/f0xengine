//; DMAT entry structure

//; $00			= mode
//; $01-$02		= size
//; $03-$05		= src
//; $06-$07		= dest

//; 8 entries, 64 bytes (DMAT_SIZE * MAX_ENTRIES)

//; DMAT status

//; one byte, bitfield
//; 7654 3210
//; each bit number represents DMA channel status

//; set = ready for transfer, reset = none/finished

constant DMATL($0620)
constant DMAT_MAX(8)
constant DMAT_SIZE(8 * DMAT_MAX)
constant DMASL(DMATL + DMAT_SIZE + 1)
constant DMAT_MASK(DMASL+1)
constant DMAT_INDX(DMASL+2)

constant dmaMode($00)
constant dmaSize($01)
constant dmaSrc($03)
constant dmaDest($06)

//; move block of WRAM to WRAM
macro memcpy(SRC, DEST, SIZE) {

	rep #$30
	pha
	phb
	
	ldx.w #{SRC}
	ldy.w #{DEST}
	lda.w #{SIZE}
	
	mvn ({DEST} >> 16)=({SRC} >> 16)
	
	pla
	plb
	
	sep #$20
}

macro memcpyNeg(SRC, DEST, SIZE) {

	rep #$30
	pha
	phb
	
	ldx.w #{SRC}
	ldy.w #{DEST}
	lda.w #{SIZE}
	
	mvp ({DEST} >> 16)=({SRC} >> 16)
	
	pla
	plb
	
	sep #$20
}

macro memcpyb(BYTE, DEST, SIZE) {

	lda.b #{BYTE}
	sta.l {DEST}
	
	rep #$30
	pha
	phb
	
	ldx.w #{DEST}
	ldy.w #{DEST} + 1
	lda.w #{SIZE} - 2
	
	mvn ({DEST} >> 16)=({DEST} >> 16)
	
	plb
	pla
	
	sep #$20
}

macro memcpybD(BYTE, SIZE) {

	lda.b #{BYTE}
	stx.b tempWord
	sta (tempWord)
	
	rep #$30
	pha
	phb
	
	txy
	iny
	lda.w #{SIZE} - 2
	
	mvn $7E=$7E
	
	plb
	pla
	
	sep #$20
}

memcpybDyn:

	memcpybD($00, ACTOR_SIZE)

	rts

initDMAT:

	memcpyb(0, DMATL, DMAT_SIZE)
	stz.w DMASL
	stz.w DMAT_INDX
	lda.b #1
	sta.w DMAT_MASK
	
	rts

//; pushed to stack:
//; mode (8), size (16), src (24), dest (16)
addDMAQueue:

	lda.w DMASL
	bit.b #$80		//; too many queues!! abandon deck
	bne +
	

	lda.b #0
	xba
	lda.w DMAT_INDX
	asl #3				//; DMAT_INDX * 8
	tax
	lda.b dmaTemp+dmaMode
	sta.w DMATL+dmaMode,x
	rep #$20
	lda.b dmaTemp+dmaSize
	sta.w DMATL+dmaSize,x
	lda.b dmaTemp+dmaSrc
	sta.w DMATL+dmaSrc,x
	lda.b dmaTemp+dmaDest
	sta.w DMATL+dmaDest,x
	sep #$20
	lda dmaTemp+dmaSrc+2
	sta.w DMATL+dmaSrc+2,x

	inc.w DMAT_INDX
	lda.w DMASL
	ora.w DMAT_MASK
	sta.w DMASL

	lda.w DMAT_MASK
	asl
	sta.w DMAT_MASK
	
	+
	
	rts


procDMAQueues:
	
	-
	lda.w DMASL
	beq +

	rep #$20
	lda.w DMAT_INDX
	dec
	and.w #$00FF
	pha
	asl
	tax
	pla
	sep #$20
	asl #3				//; DMAT_INDX * 8
	jsr (queueDMATbl,x)

	lda.w DMASL
	lsr
	sta.w DMASL

	lda.w DMAT_MASK
	lsr
	sta.w DMAT_MASK

	dec.w DMAT_INDX
	bra -

	+
	rts

queueDMATbl:

	dw queueDMA0
	dw queueDMA1
	dw queueDMA2
	dw queueDMA3
	dw queueDMA4
	dw queueDMA5

queueDMA0:

	tax
	lda.w DMATL+dmaMode,x
	sta.w REG_VMAIN

	rep #$20
	lda.w DMATL+dmaSize,x
	sta.w REG_DAS0L

	lda.w DMATL+dmaSrc,x
	sta.w REG_A1T0L

	lda.w DMATL+dmaDest,x
	sta.w REG_VMADDL

	sep #$20
	lda.w DMATL+dmaSrc+2,x
	sta.w REG_A1B0

	lda.b #$01
	sta.w REG_DMAP0

	lda.b #$18
	sta.w REG_BBAD0

	lda.b #$01
	sta.w REG_MDMAEN
	
	rts

queueDMA1:

	tax
	lda.w DMATL+dmaMode,x
	sta.w REG_VMAIN

	rep #$20
	lda.w DMATL+dmaSize,x
	sta.w REG_DAS1L

	lda.w DMATL+dmaSrc,x
	sta.w REG_A1T1L

	lda.w DMATL+dmaDest,x
	sta.w REG_VMADDL

	sep #$20
	lda.w DMATL+dmaSrc+2,x
	sta.w REG_A1B1

	lda.b #$01
	sta.w REG_DMAP1

	lda.b #$18
	sta.w REG_BBAD1

	lda.b #$01 << 1
	sta.w REG_MDMAEN
	
	rts

queueDMA2:

	tax
	lda.w DMATL+dmaMode,x
	sta.w REG_VMAIN

	rep #$20
	lda.w DMATL+dmaSize,x
	sta.w REG_DAS2L

	lda.w DMATL+dmaSrc,x
	sta.w REG_A1T2L

	lda.w DMATL+dmaDest,x
	sta.w REG_VMADDL

	sep #$20
	lda.w DMATL+dmaSrc+2,x
	sta.w REG_A1B2

	lda.b #$01
	sta.w REG_DMAP2

	lda.b #$18
	sta.w REG_BBAD2

	lda.b #$01 << 2
	sta.w REG_MDMAEN
	
	rts

queueDMA3:

	tax
	lda.w DMATL+dmaMode,x
	sta.w REG_VMAIN

	rep #$20
	lda.w DMATL+dmaSize,x
	sta.w REG_DAS3L

	lda.w DMATL+dmaSrc,x
	sta.w REG_A1T3L

	lda.w DMATL+dmaDest,x
	sta.w REG_VMADDL

	sep #$20
	lda.w DMATL+dmaSrc+2,x
	sta.w REG_A1B3

	lda.b #$01
	sta.w REG_DMAP3

	lda.b #$18
	sta.w REG_BBAD3

	lda.b #$01 << 3
	sta.w REG_MDMAEN
	
	rts

queueDMA4:

	tax
	lda.w DMATL+dmaMode,x
	sta.w REG_VMAIN

	rep #$20
	lda.w DMATL+dmaSize,x
	sta.w REG_DAS4L

	lda.w DMATL+dmaSrc,x
	sta.w REG_A1T4L

	lda.w DMATL+dmaDest,x
	sta.w REG_VMADDL

	sep #$20
	lda.w DMATL+dmaSrc+2,x
	sta.w REG_A1B4

	lda.b #$01
	sta.w REG_DMAP4

	lda.b #$18
	sta.w REG_BBAD4

	lda.b #$01 << 4
	sta.w REG_MDMAEN
	
	rts

queueDMA5:

	tax
	lda.w DMATL+dmaMode,x
	sta.w REG_VMAIN

	rep #$20
	lda.w DMATL+dmaSize,x
	sta.w REG_DAS5L

	lda.w DMATL+dmaSrc,x
	sta.w REG_A1T5L

	lda.w DMATL+dmaDest,x
	sta.w REG_VMADDL

	sep #$20
	lda.w DMATL+dmaSrc+2,x
	sta.w REG_A1B5

	lda.b #$01
	sta.w REG_DMAP5

	lda.b #$18
	sta.w REG_BBAD5

	lda.b #$01 << 5
	sta.w REG_MDMAEN
	
	rts