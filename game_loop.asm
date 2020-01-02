//; Initalize OAM
initOAM()

//; Set the current scene pointer
//; Once scene initialization is ran, the scene pointer is set to the scene's update routine
ldx.w #sceneMap512_Init
stx.w scenePtr

gameLoop:
	
	jsr levelHandle
	jsr actorHandle

	WaitNMI()
	
	jmp gameLoop
	
//; Actor Handle routine - core of running actors in F0xEngine
//; Loops through all available actor pointers in the actor list, based on the available actor count
//; DANGEROUS ROUTINE - DO NOT MODIFY IF YOU DON'T KNOW WHAT YOU'RE LOOKING AT

actorHandle:
	
	//; Checks if actor count is zero. If so, branch out
	lda.w actorCount
	cmp #$00
	beq +
	
	//; Reset accum and index registers
	lda.b #$00
	ldx.w #$0000
	ldy.w #$0000
	
	//; Loop through each actor routine based on actor count
	- {
		clc
		adc #$01
		cmp.b #ACTOR_MAX
		beq +
		pha
		rep #$20
		lda.w actorList,x
		sta.b tempLong
		sep #$20
		lda.w actorList+2,x
		sta.b tempLong+2
		pla
		jmp [tempLong]

actorHandle_continue:		
		
		inx
		inx
		inx
		iny
		cmp.b #ACTOR_MAX
		bne -
	}
	
	+ {
		//; And we're outta here!
		rts
	}
	
levelHandle:
	
	ldx.w #$0000
	jsr (scenePtr,x)
	
	rts