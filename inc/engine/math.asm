

//; MULCND = 8-BIT
//; MULPLR = 8-BIT
//; PROD   = 16-BIT
macro mulu(MULCND, MULPLR, PROD) { 

	st{MULCND}.w REG_WRMPYA
	st{MULPLR}.w REG_WRMPYB
	
	nop
	nop
	nop
	nop
	
	ld{PROD}.w REG_RDMPYL 
}

//; MULCND = 16-BIT (MUST BE A)
//; MULPLR = 8-BIT
//; PROD   = 24-BIT
macro muls(MULCND, MULPLR, PROD) { 

	sep #$20
	st{MULCND}.w REG_M7A
	xba
	st{MULCND}.w REG_M7A

	st{MULPLR}.w REG_M7B
	
	rep #$20
	
	ld{PROD}.w REG_MPYL 
}

//; DIVD = 16-BIT
//; DIVSR = 8-BIT
//; QUOT  = 16-BIT
macro divu(DIVD, DIVSR, QUOT) {

	st{DIVD}.w REG_WRDIVL
	st{DIVSR}.w REG_WRDIVB
	
	wdm #0
	wdm #1
	wdm #2
	wdm #3
	wdm #0
	wdm #1
	wdm #2
	wdm #3
	
	ld{QUOT}.w REG_RDMPYL 
}

//; On exit: A = 8-bit
macro adc24.b(VAL1, VAL2, OUT) {

	clc
	lda.b {VAL1}
	adc.b {VAL2}
	sta.b {OUT}
	
	sep #$20
	
	lda.b {VAL1}+2
	adc.b {VAL2}+2
	sta.b {OUT}+2

}

//; On exit: A = 8-bit
macro adc24.w(VAL1, VAL2, OUT) {

	clc
	lda.w {VAL1}
	adc.w {VAL2}
	sta.w {OUT}
	
	sep #$20
	
	lda.w {VAL1}+2
	adc.w {VAL2}+2
	sta.w {OUT}+2

}

//; On exit: A = 8-bit
macro adc24.l(VAL1, VAL2, OUT) {

	clc
	lda.l {VAL1}
	adc.l {VAL2}
	sta.l {OUT}
	
	sep #$20
	
	lda.l {VAL1}+2
	adc.l {VAL2}+2
	sta.l {OUT}+2

}

macro blt24.b(SRC1, SRC2, ADDR) {
	
	rep #$30
	lda.b {SRC1}
	cmp.b {SRC2}
	bcc -
	sep #$20
	lda.b {SRC1+2}
	cmp.b {SRC2+2}
	bcc -
	bra {ADDR}
	-
}

macro blt24.w(SRC1, SRC2, ADDR) {
	
	rep #$30
	lda.w {SRC1}
	cmp.w {SRC2}
	bcc -
	sep #$20
	lda.w {SRC1+2}
	cmp.w {SRC2+2}
	bcc -
	bra {ADDR}
	-
}

macro blt24.l(SRC1, SRC2, ADDR) {
	
	rep #$30
	lda.l {SRC1}
	cmp.l {SRC2}
	bcc -
	sep #$20
	lda.l {SRC1+2}
	cmp.l {SRC2+2}
	bcc -
	bra {ADDR}
	-
}

macro bgt24.b(SRC1, SRC2, ADDR) {
	
	rep #$30
	lda.b {SRC1}
	cmp.b {SRC2}
	bcs -
	sep #$20
	lda.b {SRC1+2}
	cmp.b {SRC2+2}
	bcs -
	bra {ADDR}
	-
}

macro bgt24.w(SRC1, SRC2, ADDR) {
	
	rep #$30
	lda.w {SRC1}
	cmp.w {SRC2}
	bcs -
	sep #$20
	lda.w {SRC1+2}
	cmp.w {SRC2+2}
	bcs -
	bra {ADDR}
	-
}

macro bgt24.l(SRC1, SRC2, ADDR) {
	
	rep #$30
	lda.l {SRC1}
	cmp.l {SRC2}
	bcs -
	sep #$20
	lda.l {SRC1+2}
	cmp.l {SRC2+2}
	bcs -
	bra {ADDR}
	-
}

//; linear interpolation
linearIntr:

	phx
	tax
	tya
	
	sec
	sbc $00,s		//; Y - X
	tay
	sep #$10
	mulu(y,x,a)		//; * A
	xba				//; >> 8
	and.w #$00FF
	clc
	adc $00,s		//; + X
	
	rep #$10
	plx
	
	rts
	
randAccum:

	lda.b seed
	lsr
	rol seed+1
	bcc +
	eor.b #$B4
	+
	sta.b seed
	eor.b seed+1

	rts

sqrtA:
		phx
		ldy.w #0
		bcc _sqrt1
		iny
		ror
		lsr
_sqrt1:	
		cmp.w #$0100
		bcc +
		iny
		lsr
		lsr
		bra _sqrt1
	+	
		asl
		tax
		lda.w sqrtTable,x
_sqrt2:	
		dey
		bmi +
		asl
		bra _sqrt2
	+	
	
	plx

	rts

sqrtTable:

	dw $0000; dw $0100; dw $016A; dw $01BB; dw $0200; dw $023C; dw $0273; dw $02A5
	dw $02D4; dw $0300; dw $032A; dw $0351; dw $0377; dw $039B; dw $03BE; dw $03DF
	dw $0400; dw $0420; dw $043E; dw $045C; dw $0479; dw $0495; dw $04B1; dw $04CC
	dw $04E6; dw $0500; dw $0519; dw $0532; dw $054B; dw $0563; dw $057A; dw $0591
	dw $05A8; dw $05BF; dw $05D5; dw $05EB; dw $0600; dw $0615; dw $062A; dw $063F
	dw $0653; dw $0667; dw $067B; dw $068F; dw $06A2; dw $06B5; dw $06C8; dw $06DB
	dw $06EE; dw $0700; dw $0712; dw $0724; dw $0736; dw $0748; dw $0759; dw $076B
	dw $077C; dw $078D; dw $079E; dw $07AE; dw $07BF; dw $07CF; dw $07E0; dw $07F0
	dw $0800; dw $0810; dw $0820; dw $082F; dw $083F; dw $084E; dw $085E; dw $086D
	dw $087C; dw $088B; dw $089A; dw $08A9; dw $08B8; dw $08C6; dw $08D5; dw $08E3
	dw $08F2; dw $0900; dw $090E; dw $091C; dw $092A; dw $0938; dw $0946; dw $0954
	dw $0961; dw $096F; dw $097D; dw $098A; dw $0997; dw $09A5; dw $09B2; dw $09BF
	dw $09CC; dw $09D9; dw $09E6; dw $09F3; dw $0A00; dw $0A0D; dw $0A19; dw $0A26
	dw $0A33; dw $0A3F; dw $0A4C; dw $0A58; dw $0A64; dw $0A71; dw $0A7D; dw $0A89
	dw $0A95; dw $0AA1; dw $0AAD; dw $0AB9; dw $0AC5; dw $0AD1; dw $0ADD; dw $0AE9
	dw $0AF4; dw $0B00; dw $0B0C; dw $0B17; dw $0B23; dw $0B2E; dw $0B3A; dw $0B45
	dw $0B50; dw $0B5C; dw $0B67; dw $0B72; dw $0B7D; dw $0B88; dw $0B93; dw $0B9E
	dw $0BA9; dw $0BB4; dw $0BBF; dw $0BCA; dw $0BD5; dw $0BE0; dw $0BEB; dw $0BF5
	dw $0C00; dw $0C0B; dw $0C15; dw $0C20; dw $0C2A; dw $0C35; dw $0C3F; dw $0C4A
	dw $0C54; dw $0C5F; dw $0C69; dw $0C73; dw $0C7D; dw $0C88; dw $0C92; dw $0C9C
	dw $0CA6; dw $0CB0; dw $0CBA; dw $0CC4; dw $0CCE; dw $0CD8; dw $0CE2; dw $0CEC
	dw $0CF6; dw $0D00; dw $0D0A; dw $0D14; dw $0D1D; dw $0D27; dw $0D31; dw $0D3B
	dw $0D44; dw $0D4E; dw $0D57; dw $0D61; dw $0D6B; dw $0D74; dw $0D7E; dw $0D87
	dw $0D91; dw $0D9A; dw $0DA3; dw $0DAD; dw $0DB6; dw $0DBF; dw $0DC9; dw $0DD2
	dw $0DDB; dw $0DE4; dw $0DEE; dw $0DF7; dw $0E00; dw $0E09; dw $0E12; dw $0E1B
	dw $0E24; dw $0E2D; dw $0E36; dw $0E3F; dw $0E48; dw $0E51; dw $0E5A; dw $0E63
	dw $0E6C; dw $0E75; dw $0E7E; dw $0E87; dw $0E8F; dw $0E98; dw $0EA1; dw $0EAA
	dw $0EB2; dw $0EBB; dw $0EC4; dw $0ECC; dw $0ED5; dw $0EDE; dw $0EE6; dw $0EEF
	dw $0EF7; dw $0F00; dw $0F09; dw $0F11; dw $0F1A; dw $0F22; dw $0F2A; dw $0F33
	dw $0F3B; dw $0F44; dw $0F4C; dw $0F54; dw $0F5D; dw $0F65; dw $0F6D; dw $0F76
	dw $0F7E; dw $0F86; dw $0F8E; dw $0F97; dw $0F9F; dw $0FA7; dw $0FAF; dw $0FB7
	dw $0FBF; dw $0FC8; dw $0FD0; dw $0FD8; dw $0FE0; dw $0FE8; dw $0FF0; dw $0FF8

constant tableRAM($0D00)

//; $50 = radius
//; $51 = x
//; $52 = y
//; $53 = radius result
setCircle:

	lda.b $50
	rep #$20
	sep #$10
	tax
	txy
	mulu(x,y,a)				//; A = radius * radius
	
	rep #$10
	sta.b $53				//; Store resulto to $03-$04
	ldx.w #0				//; Clear X

	//; X = Current scanline
	circleLoop:
	txa
	lsr
	sep #$21				//; A=x/2, and go to 8-bit + set carry
	sbc.b $52				//;Subtract center y
	bcs +					//;If result was positive, ok
	eor.b #$FF
	inc						//;Otherwise, change signal
	+						
							//;Basicaly Math.abs(dy)
	cmp.b $50				//;Since dx�=r�-dy�, dx, r and dy being integers			
	bcs clear				//;dx<0 -> dy�>r� -> dy>r. If this happens, clear scanline

	phx
	sep #$10
	rep #$20
	tax
	txy
	mulu(x,y,a)
	rep #$10
	plx

	sta.b tempWord
	lda.b $53				//;Evaluate
	sec
	sbc.b tempWord			//;r�-dy� (that's dx� btw)
	clc						//;Clear carry because sqrt counts it as an extra bit

	jsr sqrtA

	//;A now contains sqrt(r�-dy�)=dx, high byte = int part, low byte = fractional part, carry = extra 1 vit
	sta.b $55				//;And so does $05-$06, we're interested in $06 though
	sep #$21				//;A = 8 bits and carry set

	lda.b $51				//;Get center x
	sbc.b $56				//;Subtract dx (carry was already set)
	bcs +					//;If carry is still set, that's our initial x pos
	lda.b #0				//;Otherwise, just use the start of the screen
	+						//;Basically we're checking if $06 > $01
	sta.w tableRAM,x		//;Set scanline initial x

	lda.b $51				//;Repeat process
	clc
	adc.b $56				//;But this time add dx
	bcc +					//;If carry is still clear, that's our final x pos
	lda.b #$FF				//;Otherwise, use the end of the screen
	+
	sta.w tableRAM+1,x		//;Set scanline final x
	rep #$20
	bra +					//;Skip next bit of code

	clear:
	rep #$20
	lda.w #$00FF			//;Xstart > XEnd
	sta tableRAM,x			//;(That clears the scanline)
	+

	inx #2
	cpx.w #$E0
	bne circleLoop

	dex
	dex
	ldy.w #0

	testTransfer:
	-
	lda tableRAM,x
	sta tableRAM+$E0,y
	dex
	dex
	iny
	iny
	cpx.w #$FFFE
	bne -


	sep #$20

	rts

circleTable:
db $F0; dw tableRAM
db $F0; dw tableRAM+($E0)
db $00