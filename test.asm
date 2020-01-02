arch snes.cpu
output "test.sfc", create

macro seek(variable offset) {
  origin ((offset & $7F0000) >> 1) | (offset & $7FFF)
  base offset
}

seek(WRAM)
sprResult:
	dw 0
tempByte:
	db 0; db 0;
tempWord:
	dw 0
actorRes:
	dw 0
actorIndex:
	dw 0
actorCount:
	db 0
ADTI:
	dw 0
APTI:
	dw 0
sprCallback:
	dw 0
SVTMode:
	db 0
DMASrc:
	dl 0
DMADst:
	dw 0
DMASize:
	dw 0
stackActID:
	db 0
stackActX:
	db 0
stackActY:
	db 0
joy1Input:
	dw 0
joy1Timer:
	db 0
HDMASet:
	db 0
DMASet:
	db 0
gameFrame:
	dw 0
trash:
	dw 0
dmaTemp:
	dw 0,0,0,0
seed:
	dw 0
scenePtr:
	dw 0
tempLong:
	dl 0
actorArgs:
	db 0
musicSourceAddr:
dl 0

marioX:
db 0

seek($8000); fill $8000 // Fill Upto $7FFF (Bank 0) With Zero Bytes
include "inc/SNES.INC"        // Include SNES Definitions
include "inc/SNES_HEADER.ASM" // Include Header & Vector Table
include "inc/SNES_SPC700.INC" // Include SPC700 Definitions & Macros
include "inc/SNES_MSU1.INC"   // Include MSU1 Definitions & Macros
include "inc/SNES_GFX.INC"    // Include Graphics Macros
include "inc/SNES_INPUT.INC"
include "inc/player.inc"
include "inc/sprites.inc"
include "inc/actor.inc"
//;include "inc/frle.inc"
include "inc/engine/math.inc"

constant SPC_DRIVER_LOC($0200)
constant actorList($0100)

seek($8000); Start:
  
  print "\nF0xEngine version 0.1\n"
  print "MasterF0x - 1/2/2019\n\n"
  
  //; Initlaize the SNES
  SNES_INIT(SLOWROM)
  
  
  //; Start SMP routines
  
  //;SPCWaitBoot()  //; Wait for the APU to boot
				 //; My dead grandma could finish a 100m jog before this thing boots
				 
  //; transfer driver data to SPC RAM
  //;TransferBlockSPC(SPCROM, SPC_DRIVER_LOC, $0800)
//;	TransferBlockSPC(SPCDIR, $0800, SPCDIR.size)
//;	TransferBlockSPC(f700Seq, $1000, f700Seq.size)
//;	TransferBlockSPC(SPCSamp, $2000, SPCSamp.size)
  //;TransferBlockSPC(nspcMus, $2200, nspcMus.size)
  //;TransferBlockSPC(nspcDir, $5100, nspcDir.size)
  //;TransferBlockSPC(nspcSet, $5250, nspcSet.size)
  //;TransferBlockSPC(nspcInst, $5270, nspcInst.size)
  //;TransferBlockSPC(nspcSamp, $5420, $8000)
  //;TransferBlockSPC(nspcSamp, $5420+$10000, nspcSamp.size-$8000)

	lda.b #0
	jsr LoadSPC

  // ;Enable Joypad NMI Reading Interrupt
  lda.b #%10000001
  sta.w REG_NMITIMEN

  ldx.w #$4B59
  stx.b seed

  lda.b #16
  sta.b actorCount
  
  //; Jump to boot screen
  //include "boot.asm"
  
  
  //; Jump to engine loop
  include "game_loop.asm"

Loop:
	jmp Loop
	
vblank:

	rep #$30
	
	phb
	phd
	pha
	phx
	phy
	
	stz.w REG_HDMAEN
	
	lda.b gameFrame
	clc
	adc.w #1
	sta.w gameFrame
	
	sep #$20
	
	updateOAM()

	jsr procDMAQueues

	setHDMAColor(grad, 3, 0, 7)

	rep #$20

	ply
	plx
	pla
	pld
	plb
	
	rti

insert yoshiSineX, "yoshi_sine_x.wave"
insert yoshiSineY, "yoshi_sine_y.wave"

OSFontData:
fill 8*64+16
insert OSFontT, "font/os_font.pic"
insert OSFontP,	"font/os_font.clr"
insert OSFontErrorP,	"font/os_font_error.clr"
insert OSFontSuccessP,	"font/os_font_success.clr"
OSHDMA:

	db 112; dw 0
	db 30; dw 0
	db 1; dw 0; db 1; dw 0; db 1; dw 0; db 1; dw 0; db 1; dw 0; db 1; dw 0; db 1; dw 1; db 1; dw 1; db 1; dw 2; db 1; dw 3; db 1; dw 3; db 1; dw 4; db 1; dw 5; db 1; dw 6; db 1; dw 7; db 1; dw 8
	db 1; dw 9; db 1; dw 11; db 1; dw 12; db 1; dw 13; db 1; dw 15; db 1; dw 16; db 1; dw 18; db 1; dw 20; db 1; dw 21; db 1; dw 23; db 1; dw 25; db 1; dw 27; db 1; dw 29; db 1; dw 31; db 1; dw 33; db 1; dw 35
	db 1; dw 37; db 1; dw 40; db 1; dw 42; db 1; dw 44; db 1; dw 47; db 1; dw 49; db 1; dw 52; db 1; dw 54; db 1; dw 57; db 1; dw 60; db 1; dw 62; db 1; dw 65; db 1; dw 68; db 1; dw 71; db 1; dw 74; db 1; dw 76
	db 1; dw 79; db 1; dw 82; db 1; dw 85; db 1; dw 88; db 1; dw 91; db 1; dw 94; db 1; dw 97; db 1; dw 101; db 1; dw 104; db 1; dw 107; db 1; dw 110; db 1; dw 113; db 1; dw 116; db 1; dw 119; db 1; dw 122; db 1; dw 126
	db 1; dw 129; db 1; dw 132; db 1; dw 135; db 1; dw 138; db 1; dw 141; db 1; dw 145; db 1; dw 148; db 1; dw 151; db 1; dw 154; db 1; dw 157; db 1; dw 160; db 1; dw 163; db 1; dw 166; db 1; dw 169; db 1; dw 172; db 1; dw 175
	db 1; dw 178; db 1; dw 181; db 1; dw 184; db 1; dw 187; db 1; dw 189; db 1; dw 192; db 1; dw 195; db 1; dw 198; db 1; dw 200; db 1; dw 203; db 1; dw 205; db 1; dw 208; db 1; dw 210; db 1; dw 213; db 1; dw 215; db 1; dw 217
	db 1; dw 220; db 1; dw 222; db 1; dw 224; db 1; dw 226; db 1; dw 228; db 1; dw 230; db 1; dw 232; db 1; dw 234; db 1; dw 236; db 1; dw 237; db 1; dw 239; db 1; dw 240; db 1; dw 242; db 1; dw 243; db 1; dw 245; db 1; dw 246
	db 1; dw 247; db 1; dw 248; db 1; dw 249; db 1; dw 250; db 1; dw 251; db 1; dw 252; db 1; dw 253; db 1; dw 254; db 1; dw 254; db 1; dw 255; db 1; dw 255; db 1; dw 256
	db 0

colorTable:
	include "inc/analColor.inc"
textColor:
	include "hdma/menu_color.inc"
scrollTable:
	include "inc/scroll.inc"
arrowYTable:
	include "inc/arrow_y.table"
arrowXTable:
	include "inc/arrow_x.table"
include "actors/boot/btext_xsine.s"
debugFont:
	include "font/Font8x8.asm"
starBGColor:
	include "inc/starcolor.inc"
blankText:
	dw $0020
	
oamHighTable:
	db 1
	db 2
	db 4
	db 8
	db 16
	db 32
	db 64
	db 128

include "inc/engine/math.asm"
print "math.asm done\n"
include "inc/engine/actor.asm"
print "actor.asm done\n"
include "inc/engine/gfx.asm"
print "gfx.asm done\n"
include "inc/engine/sprite.asm"
print "sprite.asm done\n"
include "inc/engine/cgram.asm"
print "cgram.asm done\n"
include "inc/engine/error.asm"
print "error.asm done\n"
include "inc/engine/audio.asm"
print "audio.asm done\n"
include "inc/engine/dma.asm"
print "dma.asm done\n"
include "inc/engine/sa1.asm"
print "sa1.asm done\n"
//include "inc/engine/error.asm"
include "inc/engine/usb.asm"
print "usb.asm done\n"
include "inc/engine/northen.asm"
print "northen.asm done\n"
include "inc/engine/rnc.asm"
print "rnc.asm done\n"

//include "lvl/boot/scene_boot.asm"
include "lvl/null/scene_map512.asm"
print "scene_map512.asm done\n"

include "actors/nullactor.asm"
print "nullactor.asm done\n"
include "actors/test/coin.asm"
print "coin.asm done\n"
include "actors/retrolink/icon.asm"
print "icon.asm done\n"
include "actors/test/mario.asm"
print "mario.asm done\n"

include "lvl/null/bg_hdma.asm"
print "bg_hdma.asm done\n"

include "spc700/tool/smrpg/loadspc.asm"
print "loadspc.asm done\n"

cursorSine:
	include "inc/anal_cursor_table.asm"

defineBank(1)
	
insert SPCROM, "spc700/f700.bin"
insert SPCDIR, "spc700/f700_dir.bin"
kittyAnimTable:

	dl animBunIdle; db 0
	dl animKittyWalk; db 0
	dl animKittySkid; db 0

animBunIdle:

//;defineFrameProp(CMD_NULL, 9)
//;defineFrame(sprGarfP, CMD_NULL, 0)
//;defineFrame(sprGarfP, CMD_NULL, 23)
//;defineFrame(sprGarfP+$0800, CMD_NULL, 4)
//;defineFrame(sprGarfP+$1000, CMD_NULL, 4)
//;defineFrame(sprGarfP+$1800, CMD_NULL, 4)
//;defineFrame(sprGarfP+$2000, CMD_NULL, 4)
//;defineFrame(sprGarfP+$1800, CMD_NULL, 24)
//;defineFrame(sprGarfP+$1000, CMD_NULL, 4)
//;defineFrame(sprGarfP+$0800, CMD_NULL, 4)
//;defineFrame(sprGarfP, CMD_NULL, 4)

animKittyWalk:

//;defineFrameProp(CMD_NULL, 8)
//;defineFrame(sprGarfP+$2000+($0800*1), CMD_NULL, 4)
//;defineFrame(sprGarfP+$2000+($0800*2), CMD_NULL, 4)
//;defineFrame(sprGarfP+$2000+($0800*3), CMD_NULL, 4)
//;defineFrame(sprGarfP+$2000+($0800*4), CMD_NULL, 4)
//;defineFrame(sprGarfP+$2000+($0800*5), CMD_NULL, 4)
//;defineFrame(sprGarfP+$2000+($0800*6), CMD_NULL, 4)
//;defineFrame(sprGarfP+$2000+($0800*7), CMD_NULL, 4)
//;defineFrame(sprGarfP+$2000+($0800*8), CMD_NULL, 4)

animKittySkid:
//;defineFrameProp(CMD_NULL, 6)
//;defineFrame(sprGarfP+$2000+($0800*9), CMD_NULL, 0)
//;defineFrame(sprGarfP+$2000+($0800*9), CMD_NULL, 2)
//;defineFrame(sprGarfP+$2000+($0800*10), CMD_NULL, 3)
//;defineFrame(sprGarfP+$2000+($0800*11), CMD_NULL, 3)
//;defineFrame(sprGarfP_2, CMD_NULL, 3)
//;defineFrame(sprGarfP_2+$0800, CMD_NULL, 3)

bombTbl:

	db 20

	//;defineMacroSprite(0, 0, OBJ_LARGE, 0, 48)
	//;defineMacroSprite(16, 0, OBJ_LARGE, 2, 48)
	//;defineMacroSprite(32, 0, OBJ_LARGE, 4, 48)
	//;defineMacroSprite(48, 0, OBJ_LARGE, 6, 48)
//;
	//;defineMacroSprite(0, 16, OBJ_LARGE, 8, 48)
	//;defineMacroSprite(16, 16, OBJ_LARGE, 10, 48)
	//;defineMacroSprite(32, 16, OBJ_LARGE, 12, 48)
	//;defineMacroSprite(48, 16, OBJ_LARGE, 14, 48)
//;
	//;defineMacroSprite(0, 32, OBJ_LARGE, 32, 48)
	//;defineMacroSprite(16, 32, OBJ_LARGE, 34, 48)
	//;defineMacroSprite(32, 32, OBJ_LARGE, 36, 48)
	//;defineMacroSprite(48, 32, OBJ_LARGE, 38, 48)
//;
	//;defineMacroSprite(0, 48, OBJ_LARGE, 40, 48)
	//;defineMacroSprite(16, 48, OBJ_LARGE, 42, 48)
	//;defineMacroSprite(32, 48, OBJ_LARGE, 44, 48)
	//;defineMacroSprite(48, 48, OBJ_LARGE, 46, 48)
//;
	//;defineMacroSprite(0, 64, OBJ_LARGE, 64, 48)
	//;defineMacroSprite(16, 64, OBJ_LARGE, 66, 48)
	//;defineMacroSprite(32, 64, OBJ_LARGE, 68, 48)
	//;defineMacroSprite(48, 64, OBJ_LARGE, 70, 48)

insert bgGardenP,	"bg/null/garden.pic"
insert bgGardenM,	"bg/null/garden.map"
insert bgGardenC,	"bg/null/garden.clr"



defineBank(2)

insert OSDbgBGT,	"bg/null/os_dbg_bg.pic"
insert OSDbgBGM,	"bg/null/os_dbg_bg.map"
insert OSDbgBGP,	"bg/null/os_dbg_bg.clr"
insert OSBG2P,		"bg/null/os_bg2.pic"
insert OSBG2M,		"bg/null/os_bg2.map"
insert OSBG2C,		"bg/null/os_bg2.clr"

insert sprVST,	"sprite/test/icon_vs.pic"
insert sprVSP,	"sprite/test/icon_vs.clr"
insert sprNewsT,	"sprite/test/icon_news.pic"
insert sprMailT,	"sprite/test/icon_mail.pic"
insert sprExitT,	"sprite/test/icon_exit.pic"
insert sprFightT,	"sprite/test/icon_fight.pic"
insert sprToolsT,	"sprite/test/icon_tools.pic"

insert bgBoardT,	"bg/null/tic_board.pic"
insert bgBoardM,	"bg/null/tic_board.map"
insert bgBoardP,	"bg/null/tic_board.clr"

insert sprBallT,	"sprite/test/bunn.pic"
insert sprBallP,	"sprite/test/bunn.clr"

null:
dw 0

f0xengine_credits:
	db "F0xEngine 4/21/2018 v0.1  "
	

waitTxt:
db "REQUESTING.."

connectedTxt:
db "DEVICE CONNECTED!"
actorLUT:
	dw nullActor

defineBank(3)

iconTbl:
	
	db 4

	defineMacroSprite(0, 0, OBJ_LARGE, 0, 48)
	defineMacroSprite(16, 0, OBJ_LARGE, 2, 48)
	defineMacroSprite(0, 16, OBJ_LARGE, 4, 48)
	defineMacroSprite(16, 16, OBJ_LARGE, 6, 48)

controllerTbl:

	db 16

	defineMacroSprite(0, 0, OBJ_LARGE, 0, 48)
	defineMacroSprite(16, 0, OBJ_LARGE, 2, 48)
	defineMacroSprite(32, 0, OBJ_LARGE, 4, 48)
	defineMacroSprite(48, 0, OBJ_LARGE, 6, 48)

	defineMacroSprite(0, 16, OBJ_LARGE, 8, 48)
	defineMacroSprite(16, 16, OBJ_LARGE, 10, 48)
	defineMacroSprite(32, 16, OBJ_LARGE, 12, 48)
	defineMacroSprite(48, 16, OBJ_LARGE, 14, 48)

	defineMacroSprite(0, 32, OBJ_LARGE, 32, 48)
	defineMacroSprite(16, 32, OBJ_LARGE, 34, 48)
	defineMacroSprite(32, 32, OBJ_LARGE, 36, 48)
	defineMacroSprite(48, 32, OBJ_LARGE, 38, 48)

	defineMacroSprite(0, 48, OBJ_LARGE, 40, 48)
	defineMacroSprite(16, 48, OBJ_LARGE, 42, 48)
	defineMacroSprite(32, 48, OBJ_LARGE, 44, 48)
	defineMacroSprite(48, 48, OBJ_LARGE, 46, 48)


marioTbl:
	
	db 2

	defineMacroSprite(0, 0, OBJ_LARGE, 0, 48)
	defineMacroSprite(0, 16, OBJ_LARGE, 2, 48)

marioAnimTable:

	dl marioAnimIdle; db 0
	dl marioAnimWalk; db 0
	dl marioAnimPlant; db 0
	dl marioAnimWater; db 0

marioAnimIdle:

defineFrameProp(CMD_NULL, 1)
defineFrame(sprMarioP, CMD_NULL, 1)

marioAnimWalk:

defineFrameProp(CMD_NULL, 3)
defineFrame(sprMarioP+$100, CMD_NULL, 8)
defineFrame(sprMarioP+$180, CMD_NULL, 8)
defineFrame(sprMarioP+$400, CMD_NULL, 8)

marioAnimPlant:

defineFrameProp(CMD_NULL, 1)
defineFrame(sprMarioP+$0080, CMD_NULL, 1)

marioAnimWater:

defineFrameProp(CMD_NULL, 1)
defineFrame(sprMarioP+$0100, CMD_NULL, 1)

iconAnimTable:

	dl iconAnimWalk; db 0

iconAnimWalk:

defineFrameProp(CMD_NULL, 3)
defineFrame(sprNews2P, CMD_NULL, 12)
defineFrame(sprNews2P+$100, CMD_NULL, 12)
defineFrame(sprNews2P+$400, CMD_NULL, 12)

nSprTbl:
	db 1
	defineMacroSprite(0, 0, OBJ_LARGE, 0, 48)
iSprTbl:
	db 1
	defineMacroSprite(0, 0, OBJ_LARGE, 2, 48)

smallTeapotTbl:

	db 1
	defineMacroSprite(0, 0, OBJ_LARGE, 0, 48)

dirtTbl:

	db 1
	defineMacroSprite(0, 0, OBJ_LARGE, 2, 48)

waterTbl:

	db 1
	defineMacroSprite(0, 0, OBJ_LARGE, 4, 48)
	
SVTSizeTable:
	dw 0
	dw $400
	dw $800
	dw $C00
	dw $1000
	dw $1400
	dw $1800
	dw $1C00
	dw $2000
	dw $2400
	dw $2800
	dw $2C00
	
SVTCharTable:
	db 0
	db $20
	db $40
	db $60
	db $80
	db $A0
	db $C0
	db $E0
	db $00
	db $20
	db $40
	db $60

bombAnimTable:

	dl bombAnimWalk; db 0

bombAnimWalk:

//;defineFrameProp(CMD_NULL, 20)
//;defineFrame(sprBombP, CMD_NULL, 4)
//;defineFrame(sprBombP+($C00*1), CMD_NULL, 4)
//;defineFrame(sprBombP+($C00*2), CMD_NULL, 4)
//;defineFrame(sprBombP+($C00*3), CMD_NULL, 4)
//;defineFrame(sprBombP+($C00*4), CMD_NULL, 4)
//;defineFrame(sprBombP+($C00*5), CMD_NULL, 4)
//;defineFrame(sprBombP+($C00*6), CMD_NULL, 4)
//;defineFrame(sprBombP+($C00*7), CMD_NULL, 4)
//;defineFrame(sprBombP+($C00*8), CMD_NULL, 4)
//;defineFrame(sprBombP+($C00*9), CMD_NULL, 4)
//;defineFrame(sprBombP2, CMD_NULL, 4)
//;defineFrame(sprBombP2+($C00*1), CMD_NULL, 4)
//;defineFrame(sprBombP2+($C00*2), CMD_NULL, 4)
//;defineFrame(sprBombP2+($C00*3), CMD_NULL, 4)
//;defineFrame(sprBombP2+($C00*4), CMD_NULL, 4)
//;defineFrame(sprBombP2+($C00*5), CMD_NULL, 4)
//;defineFrame(sprBombP2+($C00*6), CMD_NULL, 4)
//;defineFrame(sprBombP2+($C00*7), CMD_NULL, 4)
//;defineFrame(sprBombP2+($C00*8), CMD_NULL, 4)
//;defineFrame(sprBombP2+($C00*9), CMD_NULL, 4)


defineBank(4)

defineBank(5)

insert SPCSamp, "spc700/f700_samples.bin"

defineBank(7)

insert bgTestMapT,	"bg/null/test_logo.pic"
insert bgTestMapM,	"bg/null/test_logo.map"
insert bgTestMapP,	"bg/null/test_logo.clr"

glbTextLUT:
	dw txt1
	dw txt2
	dw txt3
	dw txt4

txt1:
	db 12; db "GOOD MORNING"
txt2:
	db 8; db "HELLO!!!"
txt3:
	db 8; db "5A22 sux"
txt4:
	db 17; db "text look-up test"

insert f700Driver, "spc700/f700.bin"
insert f700Seq,	   "spc700/f700_seqs.bin"

circleSprTbl:

crossSprTbl:

ballSprTable:

ballSprTableLeft:

garfSprTbl:

garfSprTblLeft:

defineBank(8)

//;db "this bank is entirely reserved for exception handling"
//;db "it's not mandatory so you can delete it in a release ROM"
//;db "just don't forget to remove the exception hooks (COP/BRK vectors)"

defineBank(9)

insert sprMarioP,     "sprite/test/garden_mario.pic"
insert sprMarioC,     "sprite/test/garden_mario.clr"
insert sprNews2P, "sprite/test/news2.pic"
insert sprNews2C, "sprite/test/news2.clr"
insert sprNintendoP, "sprite/test/nintendo.pic"
insert sprNintendoC, "sprite/test/nintendo.clr"
insert sprCoinP,     "sprite/test/coin.pic"
insert sprCoinC,     "sprite/test/coin.clr"
insert bgNintendoP,  "bg/null/nintendo_logo.pic"
insert bgNintendoC,  "bg/null/nintendo_logo.clr"
insert bgNintendoM,  "bg/null/nintendo_logo.map"
insert bgRPGP,	     "bg/null/rpg.pic"
insert bgRPGM,	     "bg/null/rpg.map"
insert bgRPGC,	     "bg/null/rpg.clr"
insert sprBombC, "sprite/test/3dcat.clr"

defineBank($A)

//;insert bgNP00, "bg/null/n_0.pic"

defineBank($B)

insert bgNP01, "bg/null/n_1.pic"
insert bgNM,   "bg/null/n.map"
insert bgNC,   "bg/null/n.clr"

defineBank($C)
insert spcRegs, "spc700/tool/smrpg/rose.spc", $00025, $0008
seek($0CC000)
insert dspRegs, "spc700/tool/smrpg/rose.spc", $10100, $0080


defineBank($D)
 insert musicLow, "spc700/tool/smrpg/rose.spc", $0100, $8000

defineBank($E)
 insert musicHigh, "spc700/tool/smrpg/rose.spc", $8100, $8000

defineBank($F)
insert bgWaterMeterP, "bg/null/water_meter.pic"
insert bgWaterMeterC, "bg/null/water_meter.clr"
insert sprWaterPotSP, "sprite/test/waterpot_small.pic"
insert sprWaterPotSC, "sprite/test/waterpot_small.clr"
insert sprDoSeedP, "sprite/test/dopress.pic"
insert sprDoSeedC, "sprite/test/dopress.clr"
insert sprRefillP, "sprite/test/refill.pic"
insert sprRefillC, "sprite/test/refill.clr"