
bombActor_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$58
	jsr setActorType
	
	ldy.w #sprBombC
	ldx.w #sprBombC.size
	lda.b #sprBombC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprBombP
	ldy.w #$0c00
	lda.b #sprBombP >> 16
	jsr allocateSVTEntry
	
	ldx.w #bombTbl
	lda.b #bombTbl >> 16
	jsr renderOAM

	lda.b #0
	jsr setActorAnim
	
	ldx.w #bombActor_Update
	lda.b #bombActor_Update >> 16
	jsr f_setActorUpdate

	lda.b #1
	sta.w $2140
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

bombActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

	ldx.w #bombTbl
	lda.b #bombTbl >> 16
	jsr updateMetaSprites

	ldx.w #bombAnimTable
	lda.b #bombAnimTable >> 16
	jsr processADMAA

	rep #$20
	ldx.b ADTI
	lda.w actor.x,x
	dec
	//sta.w actor.x,x
	sep #$20

	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

nintendoActor_Init: {
	
	pha
	phy
	phx
	
	jsr f_initActorDP
	
	lda.b #$56
	jsr setActorType
	
	ldy.w #sprNintendoC
	ldx.w #sprNintendoC.size
	lda.b #sprNintendoC >> 16
	jsr allocateSPTEntry
	
	ldx.w #sprNintendoP
	ldy.w #$0400
	lda.b #sprNintendoP >> 16
	jsr allocateSVTEntry
	
	ldx.w #nSprTbl
	lda.b #nSprTbl >> 16
	jsr renderOAM
	
	ldx.w #nintendoActor_Update
	lda.b #nintendoActor_Update >> 16
	jsr f_setActorUpdate
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

nintendoActor_Update: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

	ldx.b ADTI
	lda.w 8,x
	sta.w 6,x

	lda.b #$FE
	sta.w actor.x+1,x
	
	ldx.w #nSprTbl
	lda.b #nSprTbl >> 16
	jsr updateMetaSprites

    ldx.w ADTI
    lda.b #$30
    sta.w actor.tileFlags,x

	rep #$20
	lda.w 12,x
	cmp.w #117
	beq +
	
	tdc
	lda.w 12,x
	pha
	tax
	sep #$20
	lda.l nintendoActor_bounceTbl,x
	ldx.b ADTI
	sta.w actor.y,x
	rep #$20
	pla
	inc
	sta.w 12,x

	+
	sep #$20

	ldx.b gameFrame
	cpx.w #$0100
	bcc +
	jsr f_resetADB
	ldx.w #nintendoActor_UpdateSine
	lda.b #nintendoActor_UpdateSine >> 16
	jsr f_setActorUpdate
	jsr f_setADB

	rep #$20
	ldx.b ADTI
	tdc
	sta.w 10,x
	sta.w 12,x

	lda.w actor.x,x
	sta.w 8,x
	lda.w actor.y,x
	sta.w 10,x
	sep #$20

	lda.b $86
	sta.w 14,x
	eor.b #1
	sta.b $86

	+
	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

nintendoActor_UpdateSine: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

	ldx.w #nSprTbl
	lda.b #nSprTbl >> 16
	jsr updateMetaSprites

	rep #$20
	lda.w 12,x
	cmp.w #400
	bcs +
	
	tdc
	ldx.b ADTI
	lda.w 12,x
	tax
	lda.l nintendoActor_sineTable,x
	sta.b tempWord
	stx.b tempLong
	ldx.b ADTI
	lda.w 14,x
	and.w #$00FF
	beq +
	lda.b tempWord
	ldx.b tempLong
	eor.w #$FFFF
	inc
	bra ++
	+
	lda.b tempWord
	ldx.b tempLong
	+
	ldx.b ADTI
	clc
	adc.w 8,x
	sta.w actor.x,x
	
	inc 12,x
	inc 12,x

	tdc
	ldx.b ADTI
	lda.w 12,x
	tax
	lda.l nintendoActor_sineTable,x
	and.w #$00FF
	ldx.b ADTI
	clc
	adc.w 10,x
	sta.w actor.y,x
	
	inc 12,x

	+
	sep #$20

	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

nintendoActor_UpdateScroll: {

	pha
	phy
	phx
	
	sty.w actorIndex
	jsr f_actPropDP
    
    jsr f_setADB

	ldx.w #nSprTbl
	lda.b #nSprTbl >> 16
	jsr updateMetaSprites

	rep #$20
	ldx.b ADTI
	lda.w actor.x,x
	inc
	sta.w actor.x,x
	sep #$20

	jsr f_resetADB
	
	plx
	ply
	pla
	
	jml actorHandle_continue
}

nintendoActor_bounceTbl:
db 223
db 226
db 229
db 233
db 237
db 241
db 246
db 246
db 0
db 5
db 11
db 18
db 21
db 29
db 39
db 43
db 56
db 64
db 70
db 68
db 63
db 59
db 52
db 49
db 44
db 41
db 39
db 36
db 33
db 32
db 30
db 29
db 29
db 28
db 28
db 29
db 29
db 31
db 32
db 35
db 37
db 40
db 41
db 46
db 51
db 55
db 59
db 65
db 71
db 71
db 68
db 65
db 63
db 60
db 58
db 56
db 55
db 54
db 54
db 54
db 54
db 54
db 56
db 57
db 59
db 60
db 62
db 65
db 70
db 73
db 71
db 70
db 68
db 67
db 66
db 66
db 66
db 67
db 67
db 69
db 71
db 72
db 73
db 72
db 71
db 70
db 70
db 70
db 71
db 72
db 73
db 73
db 72
db 72
db 71
db 72
db 72
db 73
db 73
db 72
db 72
db 72
db 73
db 73
db 73
db 73
db 72
db 73
db 73
db 73
db 73
db 73
db 73
db 73
db 73
db 73
db 74
db 74


nintendoActor_sineTable:
dw 0
db 1
dw 0
db 1
dw 0
db 1
dw 0
db 2
dw 0
db 2
dw 0
db 2
dw 0
db 3
dw 1
db 3
dw 1
db 4
dw 1
db 4
dw 2
db 5
dw 2
db 6
dw 2
db 6
dw 2
db 7
dw 3
db 8
dw 3
db 8
dw 3
db 9
dw 3
db 10
dw 3
db 11
dw 3
db 12
dw 3
db 13
dw 3
db 14
dw 3
db 15
dw 2
db 16
dw 2
db 17
dw 2
db 18
dw 1
db 20
dw 1
db 21
dw 0
db 22
dw 0
db 23
dw -1
db 24
dw -2
db 25
dw -3
db 26
dw -4
db 27
dw -5
db 28
dw -7
db 29
dw -8
db 30
dw -10
db 31
dw -11
db 31
dw -13
db 32
dw -15
db 32
dw -17
db 33
dw -19
db 33
dw -21
db 33
dw -23
db 33
dw -25
db 33
dw -28
db 32
dw -30
db 31
dw -32
db 31
dw -34
db 29
dw -36
db 28
dw -39
db 27
dw -41
db 25
dw -42
db 23
dw -44
db 21
dw -46
db 19
dw -47
db 16
dw -49
db 14
dw -50
db 11
dw -50
db 8
dw -51
db 5
dw -51
db 1
dw -51
db -1
dw -51
db -4
dw -50
db -8
dw -49
db -11
dw -48
db -14
dw -46
db -17
dw -44
db -21
dw -41
db -23
dw -38
db -26
dw -35
db -29
dw -32
db -31
dw -28
db -32
dw -24
db -34
dw -20
db -35
dw -15
db -35
dw -11
db -35
dw -6
db -34
dw -2
db -33
dw 2
db -32
dw 6
db -30
dw 10
db -27
dw 14
db -24
dw 17
db -20
dw 20
db -16
dw 23
db -11
dw 25
db -6
dw 26
db -1
dw 27
db 4
dw 27
db 9
dw 26
db 15
dw 25
db 21
dw 23
db 26
dw 20
db 31
dw 16
db 36
dw 11
db 40
dw 6
db 44
dw 1
db 47
dw -4
db 50
dw -11
db 51
dw -17
db 52
dw -24
db 52
dw -31
db 50
dw -37
db 48
dw -44
db 45
dw -50
db 41
dw -55
db 35
dw -59
db 30
dw -63
db 23
dw -66
db 16
dw -67
db 8
dw -68
db 0
dw -67
db -7
dw -65
db -14
dw -61
db -22
dw -57
db -29
dw -51
db -35
dw -44
db -40
dw -37
db -45
dw -29
db -48
dw -20
db -49
dw -11
db -50
dw -2
db -48
dw 6
db -45
dw 14
db -41
dw 22
db -35
dw 28
db -28
dw 34
db -20
dw 38
db -11
dw 40
db -1
dw 40
db 8
dw 39
db 18
dw 36
db 28
dw 31
db 37
dw 25
db 46
dw 16
db 53
dw 7
db 58
dw -2
db 62
dw -13
db 64
dw -24
db 64
dw -35
db 62
dw -46
db 57
dw -56
db 51
dw -64
db 43
dw -71
db 33
dw -76
db 22
dw -79
db 10
dw -79
db -2
dw -77
db -14
dw -72
db -26
dw -65
db -36
dw -56
db -45
dw -45
db -53
dw -33
db -58
dw -20
db -60
dw -7
db -60
dw 6
db -57
dw 18
db -51
dw 29
db -43
dw 38
db -32
dw 45
db -20
dw 49
db -6
dw 51
db 7
dw 49
db 22
dw 43
db 36
dw 35
db 48
dw 25
db 59
dw 12
db 67
dw -2
db 72
dw -17
db 74
dw -33
db 72
dw -48
db 67
dw -61
db 59
dw -73
db 47
dw -81
db 33
dw -87
db 18
dw -88
db 1
dw -86
db -14
dw -80
db -30
dw -70
db -44
dw -58
db -56
dw -42
db -64
dw -25
db -69
dw -7
db -69
dw 9
db -65
dw 25
db -57
dw 39
db -45
dw 50
db -30
dw 57
db -13
dw 59
db 5
dw 57
db 24
dw 50
db 41
dw 39
db 57
dw 24
db 70
dw 7
db 78
dw -12
db 82
dw -32
db 81
dw -51
db 75
dw -68
db 64
dw -82
db 49
dw -92
db 30
dw -96
db 10
dw -95
db -10
dw -89
db -30
dw -78
db -48
dw -62
db -63
dw -42
db -73
dw -21
db -77
dw 0
db -76
dw 22
db -68
dw 40
db -56
dw 54
db -38
dw 64
db -17
dw 67
db 5
dw 64
db 28
dw 54
db 49
dw 39
db 68
dw 20
db 81
dw -2
db 89
dw -26
db 89
dw -50
db 83
dw -71
db 71
dw -88
db 53
dw -99
db 31
dw -104
db 6
dw -101
db -18
dw -91
db -42
dw -74
db -62
dw -53
db -76
dw -28
db -84
dw -1
db -83
dw 23
db -76
dw 45
db -60
dw 62
db -39
dw 72
db -14
dw 74
db 12
dw 67
db 39
dw 53
db 63
dw 32
db 82
dw 6
db 93
dw -21
db 97
dw -49
db 91
dw -74
db 77
dw -94
db 56
dw -107
db 30
dw -110
db 0
dw -105
db -28
dw -91
db -54
dw -69
db -75
dw -41
db -87
dw -11
db -91
dw 18
db -85
dw 45
db -69
dw 66
db -46
dw 78
db -17
dw 80
db 14
dw 72
db 45
dw 54
db 71
dw 29
db 91
dw -1
db 102
dw -34
db 102
dw -65
db 91
dw -91
db 70
dw -109
db 42
dw -116
db 9
dw -113
db -24
dw -98
db -54
dw -74
db -79
dw -43
db -93
dw -8
db -97
dw 25
db -88
dw 54
db -69
dw 75
db -40
dw 86
db -6
dw 84
db 29
dw 69
db 62
dw 44
db 88
dw 11
db 105
dw -24
db 109
dw -60
db 100
dw -91
db 78
dw -113
db 48
dw -122
db 11
dw -118
db -26
dw -101
db -60
dw -73
db -86
dw -37
db -101
dw 1
db -101
dw 38
db -88
dw 68
db -62
dw 87
db -27
dw 92
db 12
dw 82
db 51
dw 58
db 84
dw 24
db 106
dw -15
db 114
dw -56
db 107
dw -91
db 86
dw -116
db 53
dw -128
db 12
dw -123
db -29
dw -103
db -66
dw -70
db -94
dw -29
db -107
dw 13
db -104
dw 52
db -85
dw 81
db -53
dw 96
db -11
dw 94
db 32
dw 75
db 72
dw 42
db 103
dw 0
db 118
dw -45
db 116
dw -86
db 97
dw -117
db 63

coinActor_bounceTbl:
db 0
db 3
db 5
db 8
db 11
db 7
db 11
db 13
db 14
db 16
db 18
db 19
db 21
db 23
db 24
db 26
db 27
db 29
db 30
db 32
db 33
db 34
db 36
db 37
db 39
db 39
db 41
db 42
db 44
db 45
db 46
db 47
db 48
db 49
db 50
db 51
db 52
db 53
db 54
db 55
db 55
db 57
db 58
db 58
db 59
db 60
db 61
db 62
db 62
db 63
db 64
db 65
db 65
db 66
db 66
db 67
db 67
db 68
db 68
db 68
db 69
db 69
db 70
db 70
db 70
db 71
db 71
db 71
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 72
db 71
db 71
db 71
db 71
db 70
db 70
db 70
db 69
db 69
db 69
db 68
db 68
db 67
db 67
db 66
db 65
db 65
db 64
db 64
db 63
db 62
db 61
db 61
db 60
db 59
db 59
db 58
db 57
db 55
db 55
db 53
db 52
db 52
db 51
db 49
db 48
db 47
db 46
db 45
db 44
db 43
db 42
db 41
db 39
db 38
db 36
db 35
db 33
db 32
db 31
db 30
db 28
db 27
db 24
db 23
db 21
db 19
db 19
db 18
db 14
db 14
db 11
db 9
db 7
db 5
db 5
db 2
db 1
db 0
db -2
db -4
db -6
db -7
db -10
db -13
db -15
db -17
db -18
db -20
db -22
db -26
db -28
db -30
db -32
db -34
db -37
db -39
db -42
db -43
db -45
db -47
db -52
db -55
db -55
db -58
db -60
db -63
db -65
db -70
db -72
db -75
db -79
db -79
db -84
db -86
db -88
db -91
db -95
db -98
db -101
db -104
db -107
db -110
db -114
db -117
db -119
db -122
db -125
db -128
db -131
db -134
db -139
db -142
db -143
db -146
db -152
db -154
db -157
db -160
db -166
db -168
db -171
db -174
db -180
db -182
db -185
db -188
db -194
db -197