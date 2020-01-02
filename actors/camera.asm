
cameraControl: {
	
	phb
	
	//jsr cameraInput
	
	plb
	rts
}

cameraInput: {
	
	ReadJOY({JOY_RIGHT})
	bne cam_scroll_left
	ReadJOY({JOY_LEFT})
	bne cam_scroll_right
	
	rts
}

cam_scroll_left: {
	
	lda.w cameraX
	adc #$01
	sta.w cameraX
	rts
}

cam_scroll_right: {
	
	lda.w cameraX
	dec #$01
	sta.w cameraX
	rts
}