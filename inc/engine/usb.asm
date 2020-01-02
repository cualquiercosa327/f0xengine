
//; retro.live prototype USB registers

constant USB_FIFO($21C0)
constant USB_STAT($21C1)

constant UFO_SRAM_SIZE($002184) //; SRAM size/mapping, DRAM size (high bits)
constant UFO_MAP_SRAM($002185) //; SRAM mapping
constant UFO_DRAM_SIZE($002186) //; DRAM size (lowest bits)
constant UFO_MAP_GAME($002187) //; DRAM/cart mapping
constant UFO_MAP_ROM($002188) //; LoROM/HiROM
constant UFO_MAP_SEL($002189) //; game select
constant UFO_MAP_MODE($00218A) //; BIOS/update/game mode select
constant UFO_MAP_EN($00218B) //; mapper enable

constant MAP_SEL_DRAM($00)
constant MAP_SEL_CART($03)

constant MAP_MODE_UFO($00)
constant MAP_MODE_UPDATE($0A)
constant MAP_MODE_GAME($FF)

constant MAP_ENABLE($0A)

constant USB_STATUS_ERROR($80)
constant USB_STATUS_BUSY($40)

constant USB_STATUS($002188)
constant USB_DATA($00218C)
constant USB_CMD($00218E)

constant USB_BUF_SIZE($40)

constant GET_IC_VER($01)
constant SET_BAUDRATE($02)
constant ENTER_SLEEP($03)
constant RESET_ALL($05)
constant CHECK_EXIST($06)
constant SET_SD0_INT($0B)
constant GET_FILE_SIZE($0C)
constant USB_ID($12)
constant USB_MODE($15)
constant GET_STATUS($22)
constant USB_UNLOCK($23)
constant USB_DATA0($27)
constant USB_DATAR($28)
constant USB_DATA5($2A)
constant USB_DATA7($2B)
constant USB_DATAW($2C)
constant WR_REQ_DATA($2D)
constant WR_OFS_DATA($2E)

constant CMD_RET_SUCCESS($51)
constant CMD_RET_ABORT($5F)

constant USB_INT_EP2_OUT($02)
constant USB_INT_EP2_IN($0a)
constant USB_INT_WAKE_UP($06)
constant USB_INT_SUCCESS($14)
constant USB_INT_CONNECT($15)
constant USB_INT_DISCONNECT($16)
constant USB_INT_BUF_OVER($17)
constant USB_READY($18)

constant UFO_VENDOR_ID($1292)
constant UFO_PRODUCT_ID($4653)


USBReset:

	lda.b #RESET_ALL
	sta.w USB_CMD
	
	rts

USBSetPVID:

	//; set USB VID/PID
	lda.b #USB_ID
	sta.w USB_CMD
	lda.b #UFO_VENDOR_ID
	sta.w USB_DATA
	lda.b #UFO_VENDOR_ID >> 8
	sta.w USB_DATA
	lda.b #UFO_PRODUCT_ID
	sta.w USB_DATA
	lda.b #UFO_PRODUCT_ID >> 8
	sta.w USB_DATA
	
	rts
	
USBSetMode:

	//; set USB to internal firmware/USB device mode
	lda.b #USB_MODE
	sta.w USB_CMD
	WaitNMI()
	lda.b #$02
	sta.w USB_DATA
	
	rts

UFOEnable:

	lda.b #MAP_ENABLE
	sta.w UFO_MAP_EN
	stz.w UFO_MAP_MODE
	
	rts

UFODisable:

	inc UFO_MAP_MODE
	stz.w UFO_MAP_EN
	rts

DRAMEnable:

	stz.w UFO_MAP_SEL
	rts

DRAMDisable:
	
	lda.b #MAP_SEL_CART
	sta.w UFO_MAP_SEL
	
	rts
	
USBUnlock:

	lda.b #USB_UNLOCK
	sta.w USB_CMD
	
	rts
	
USBRecv:

	lda.b #USB_DATAR
	sta.w USB_CMD
	nop
	
	ldx.w #64
	ldy.w #0
	
	-
	lda.w USB_DATA
	sta $0000,y
	nop
	iny
	dex
	bne -
	
	rts
	
USBSend:

	lda.b #USB_DATA7
	sta.w USB_CMD
	nop

	lda.b $00
	tax
	stz.b $68
	stz.b $69
	
	-
	lda [$68]
	sta.w USB_DATA
	nop
	inc $68
	dex
	bne -
	
	rts