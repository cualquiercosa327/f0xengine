
//; 16.16 fixed-point

constant right($00)
constant left($01)

constant SHIFT_BASE(8)
constant SHIFT_MASK((1 << SHIFT_BASE) - 1)

macro shift(DIR, AMOUNT) {

	phy
	ldy.w #0
	
	{#}shiftLoop:
	
		cpy.w #{AMOUNT}
		beq {#}endShift
		if {DIR} == right {
			lsr
		} else {
			asl
		}
		iny
		bra {#}shiftLoop
		
	{#}endShift:
	
		ply
}