//;---------------------------------------------------------
//; PRO-PACK Unpack Source Code - Super NES, Method 1
//;
//; Copyright (c) 1992 Rob Northen Computing
//;
//; File: RNC_1.S
//;
//; Date: 9.03.92
//;---------------------------------------------------------

//;---------------------------------------------------------
//; Unpack Routine - Super NES, Method 1
//;
//; To unpack a packed file (in any data bank) to an output
//; buffer (in any data bank) Note: the packed and unpacked
//; files are limited to 65536 bytes in length.
//;
//; To call (assumes 16-bit accumulator)
//;
//;   PEA pack_file     //; push low word of packed file
//;   PEA ^pack_file          //; push high word of packed file
//;   PEA destn_buf     //; push low word of output buffer
//;   PEA ^destn_buf          //; push high word of output buffer
//;   JSL UNPACK              //; unpack file to output buffer
//;   PLA
//;   PLA
//;   PLA
//;   PLA
//;
//; On exit,
//;
//; A, X, Y undefined, M=0, X=0
//;---------------------------------------------------------

//;---------------------------------------------------------
//; Equates
//;---------------------------------------------------------

constant buff1($D0)                   //; 16-bit address of $21 byte z-page buffer
constant buff2($7E8000)               //; 24-bit address of $1a0 byte buffer

constant in(buff1)
constant out(in+4)
constant wrkbuf(out+2)
constant counts(wrkbuf+3)
constant blocks(counts+2)
constant bitbufl(blocks+2)
constant bitbufh(bitbufl+2)
constant bufbits(bitbufh+2)
constant bitlen(bufbits+2)
constant hufcde(bitlen+2)
constant hufbse(hufcde+2)
constant temp1(hufbse+2)
constant temp2(temp1+2)
constant temp3(temp2+2)
constant temp4(temp3+2)

constant tmptab(0)               //; indexed from buff2
constant rawtab(tmptab+$20)      //; indexed from buff2
constant postab(rawtab+$80)      //; indexed from buff2
constant slntab(postab+$80)      //; indexed from buff2

//;---------------------------------------------------------

unpack:
        rep #$39            //; 16-bit axy, clear d and c
        lda 6,s             //; read low word of output address
        sta.b out
        lda 8,s             //; read high word of packed file
        sta.b in+2
        lda 10,s            //; read low word of packed file
        sta.b in

        lda 4,s
        phb                 //; save current data bank
        xba
        pha                 //; push 2 bytes
        plb                 //; 0
        plb                 //; make output buffer default data bank
        lda.w #buff2
        sta.b wrkbuf
        lda.w #buff2 >> 16
        sta.b wrkbuf+2

        lda.w #17
        adc.b in
        sta.b in
        lda [in]
        and.w #$ffff
        sta.b blocks
        inc.b in
        lda [in]
        sta.b bitbufl
        stz.b bufbits
        lda.w #2
        jsr gtbits

unpack2:
        ldy.w #rawtab
        jsr makehuff
        ldy.w #postab
        jsr makehuff
        ldy.w #slntab
        jsr makehuff
        lda.w #16
        jsr gtbits
        sta.b counts
        jmp unpack8

unpack3:
        ldy.w #postab
        jsr gtval
        sta.b temp2
        lda.b out
        clc
        sbc.b temp2
        sta.b temp3
        ldy.w #slntab
        jsr gtval
        inc
        inc
        lsr
        tax
        ldy.w #0
        lda.b temp2
        bne unpack5
        sep #$20             //; 8-bit accumulator
        lda (temp3),y
        xba
        lda (temp3),y
        rep #$20             //; 16-bit accumulator
unpack4:
        sta (out),y
        iny
        iny
        dex
        bne unpack4
        bra unpack6
unpack5:
        lda (temp3),y
        sta (out),y
        iny
        iny
        dex
        bne unpack5
unpack6:
        bcc unpack7
        sep #$20             //; 8-bit accumulator
        lda (temp3),y
        sta (out),y
        iny
        rep #$21             //; 16-bit accumulator, clear carry
unpack7:
        tya
        adc.b out
        sta.b out

unpack8:
        ldy.w #rawtab
        jsr gtval
        tax
        beq unpack14
        ldy.w #0
        lsr
        beq unpack10
        tax
unpack9:
        lda [in],y
        sta (out),y
        iny
        iny
        dex
        bne unpack9
unpack10:
        bcc unpack11
        sep #$20         //; 8-bit accumulator
        lda [in],y
        sta (out),y
        rep #$21         //; 16-bit accumulator, clear carry
        iny
unpack11:
        tya
        adc.b in
        sta.b in
        tya
        adc.b out
        sta.b out
        stz.b bitbufh
        lda.b bufbits
        tay
        asl
        tax
        lda [in]
        cpy.w #0
        beq unpack13
unpack12:
        asl
        rol.b bitbufh
        dey
        bne unpack12
unpack13:
        sta.b temp1
        lda.l msktab,x
        and.b bitbufl
        ora.b temp1
        sta.b bitbufl
unpack14:
        dec.b counts
        beq _1
        jmp unpack3
_1:
        dec.b blocks
        beq _2
        jmp unpack2
_2:
        plb                 //; restore old data bank
        rtl

//;-----------------------------------------------------------

gtval:
        ldx.b bitbufl
        bra gtval3
gtval2:
        iny
        iny
gtval3:
        txa
        and [wrkbuf],y
        iny
        iny
        cmp [wrkbuf],y
        bne gtval2
        tya
        adc.w #(15*4+1)
        tay
        lda [wrkbuf],y
        pha
        xba
        and.w #$ffff
        jsr gtbits
        pla
        and.w #$ffff
        cmp.w #2
        bcc gtval4
        dec
        asl
        pha
        lsr
        jsr gtbits
        plx
        ora.l bittab,x
gtval4:
        rts

bittab:
        dw  1
        dw  2
        dw  4
        dw  8
        dw  $10
        dw  $20
        dw  $40
        dw  $80
        dw  $100
        dw  $200
        dw  $400
        dw  $800
        dw  $1000
        dw  $2000
        dw  $4000
        dw  $8000

//;-----------------------------------------------------------

gtbits:
        tay
        asl
        tax
        lda.l msktab,x
        and.b bitbufl
        pha
        lda.b bitbufh
        ldx.b bufbits
        beq gtbits3
gtbits2:
        lsr
        ror.b bitbufl
        dey
        beq gtbits4
        dex
        beq gtbits3
        lsr
        ror.b bitbufl
        dey
        beq gtbits4
        dex
        bne gtbits2
gtbits3:
        inc.b in
        inc.b in
        lda [in]
        ldx.w #16
        bra gtbits2
gtbits4:
        dex
        stx.b bufbits
        sta.b bitbufh
        pla
gtbits5:
        rts

msktab:
        dw  0
        dw  1
        dw  3
        dw  7
        dw  $f
        dw  $1f
        dw  $3f
        dw  $7f
        dw  $ff
        dw  $1ff
        dw  $3ff
        dw  $7ff
        dw  $fff
        dw  $1fff
        dw  $3fff
        dw  $7fff
        dw  $ffff

//;-----------------------------------------------------------

makehuff:
        sty.b temp4
        lda.w #5
        jsr gtbits
        beq gtbits5
        sta.b temp1
        sta.b temp2
        ldy.w #0
makehuff2:
        phy
        lda.w #4
        jsr gtbits
        ply
        sta [wrkbuf],y
        iny
        iny
        dec.b temp2
        bne makehuff2
        stz.b hufcde
        lda.w #$8000
        sta.b hufbse
        lda.w #1
        sta.b bitlen
makehuff3:
        lda.b bitlen
        ldx.b temp1
        ldy.w #0
makehuff4:
        cmp [wrkbuf],y
        bne makehuff8
        phx
        sty.b temp3
        asl
        tax
        lda.l msktab,x
        ldy.b temp4
        sta [wrkbuf],y
        iny
        iny
        lda.w #16
        sec
        sbc.b bitlen
        pha
        lda.b hufcde
        sta.b temp2
        ldx.b bitlen
makehuff5:
        asl.b temp2
        ror
        dex
        bne makehuff5
        plx
        beq makehuff7
makehuff6:
        lsr
        dex
        bne makehuff6
makehuff7:
        sta [wrkbuf],y
        iny
        iny
        sty.b temp4
        tya
        clc
        adc.w #(15*4)
        tay
        lda.b bitlen
        xba
        sep #$20             //; 8-bit accumulator
        lda.b temp3
        lsr
        rep #$21             //; 16-bit accumulator, clear carry
        sta [wrkbuf],y
        lda.b hufbse
        adc.b hufcde
        sta.b hufcde
        lda.b bitlen
        ldy.b temp3
        plx
makehuff8:
        iny
        iny
        dex
        bne makehuff4
        lsr.b hufbse
        inc.b bitlen
        cmp.w #16
        bne makehuffJmp
        rts

makehuffJmp:

        jmp makehuff3