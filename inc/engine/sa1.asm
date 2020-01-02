
constant REG_CCNT($2200)
constant REG_RV($2203)
constant REG_NV($2205)


//; X = Address
//; A = Bank

f_initSA1: {
	
	stx.w REG_RV
	ldx.w #sa_nmi
	stx.w REG_NV
	stz.w REG_CCNT
	rts

}

sa_main: {

	sei		//; boot out of useless ass mode (emulation) to native mode
	clc
	xce
	phk
	plb
	
	rep #$38
	
	lda.w #0
	tcd		//; set direct-page to $0000
	
	lda.w #$37FF
	tcs 	//; set stack pointer to 37FF
	
	sep #$20
	
	
	sa_loop:
	
	jmp sa_loop
}

sa_nmi: {

	rti

}