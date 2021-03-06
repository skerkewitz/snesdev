.include "header.inc"
.include "regs.inc"
.include "std.inc"

.global main
.global mem_pool


.SEGMENT "ZEROPAGE"

        ; careful with zeropage!
        ; it is used to access arguments
        ; on stack in subroutines !

.SEGMENT "BSS"

        mem_pool:   .res 64  
        scy     :   .res 1

.SEGMENT "HRAM" : FAR
.SEGMENT "HRAM2" : FAR
.SEGMENT "HDATA" : FAR
.SEGMENT "XCODE"
.SEGMENT "GRAPHICS"

.SEGMENT "CODE"

start:
        init_snes

        .a8
        .i16
        .smart

        jsr spcBoot
        lda #^__SOUNDBANK__
        jsr spcSetBank

        ldx #$0000
        jsr spcLoad

        lda #39
        jsr spcAllocateSoundRegion

        lda #^sound_table|$80
        ldy #.loword(sound_table)
        jsr spcSetSoundTable

        ldx #40
        jsr spcSetModuleVolume


        ldx #0
        jsr spcPlay
        jsr spcFlush




        ; 
        ; set BG properties
        ;

        ldx #BG1_CHR_ADDR($0000)
        stx BG12NBA
        ldx #BG3_CHR_ADDR($3000)
        stx BG34NBA

        ldx BG_MAP_ADDR($1000)
        stx BG1SC
        ldx BG_MAP_ADDR($1800)
        stx BG2SC
        ldx BG_MAP_ADDR($2000)
        stx BG3SC


        ;
        ; copy font & cgram data
        ;

        ldx #$0000
        stx VMADDL
        call g_dma_tag_2, font1_dma

        lda #$00
        sta $2121
        call g_dma_tag_2, cgdata_dma


        ;
        ; print some text
        ;


        ldx #$1000
        stx VMADDL
        puts "sound test"


        ;
        ; config & enable display
        ;

        lda #$01
        sta BGMODE
        lda #$01
        sta TM
        lda #$0f
        sta INIDISP

        ;
        ; enable NMI/joypad reading
        ;

        lda #$81
        sta $4200
        cli


main_loop: 

        jsr spcProcess
        wai

        jmp main_loop

quit:


brk_handler:
        rti
irq_handler:
        rti

nmi:

        phb
        pha
        phx
        phy
        phd


        .ifdef SWC

        jsr process_joypads
        lda joy1_held
        beq :+
                ;jsr __swc_return_to_bios
                lda #$00
                jsr spcPlaySound
        :

        .endif

        jsr spcGetCues
        beq :+

        lda scy
        dec
        sta BG1VOFS
        sta scy

        :

        lda $4210

        pld
        ply
        plx
        pla
        plb

        rti

;
; sound data
;
sound_table:


;
; screen setup and dma transfers
;
font1_dma: build_dma_tag 1,$18,font1,^font1,font_end1-font1
cgdata_dma: build_dma_tag 0,$22,colors,^colors,colors_end-colors



;
; graphics data 
;

colors:
        .byte $00,$00
        .byte $ff,$7f
        .byte $00,$00
        .byte $ff,$7f
colors_end:


font1: .incbin "font4bpp.bin"
font_end1:


