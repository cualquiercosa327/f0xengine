spc_load_data:
	
	php
	rep #$30
	
	lda.w #0
	tay

	sep #$20

	sta.l REG_NMITIMEN
	sei

	rep #$30

	lda #SPCROM.size // size
	tax
	lda #SPCROM
	sta.b SPCPtr
	lda #SPCROM >> 16
	sta.b SPCPtr+2

	lda.w #$bbaa
	
_wait1:

	cmp.l REG_APUIO0
	bne _wait1

	lda #$0200 // addr
	sta.l REG_APUIO2
	lda.w #$01cc		//IPL load and ready signature
	sta.l REG_APUIO0

	sep #$20

_wait2:

	cmp.l REG_APUIO0
	bne _wait2


	rep #$30
	lda.w #$0000
	sep #$20
	
_load1:

	lda [SPCPtr],y
	sta.w REG_APUIO1
	tya
	sta.w REG_APUIO0
	iny
	
_load2:

	cmp.w REG_APUIO0
	bne _load2
	dex
	bne _load1

	iny
	bne _load3
	iny
	
_load3:

	rep #$30

	lda.w #$0200		//loaded code starting address
	sta.l REG_APUIO2
	lda.w #$0000

	sep #$20

	lda.b #$00			//execute code
	sta.l REG_APUIO1
	tya					//stop transfer
	sta.l REG_APUIO0

_load4:

	sep #$20
	txa
	sta.l REG_NMITIMEN		//enable NMI
	cli					//enable IRQ

	rep #$30

_load5:

	lda.l REG_APUIO0			//wait until SPC700 clears all communication ports, confirming that code has started
	ora.l REG_APUIO2
	bne _load5
	lda.w #$0000
	sep #$20
	
	plp
	rts