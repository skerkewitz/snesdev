.include "header.inc"
.include "regs.inc"
.include "std.inc"

.global main
.global mem_pool
.global DEBUG_FONT_DMA,brk_info,debug_colors


.SEGMENT "ZEROPAGE"

        ; careful with zeropage!
        ; it is used to access arguments
        ; on stack in subroutines !

.SEGMENT "BSS"

        mem_pool:   .res 64  
        scroll_x:   .res 1

.SEGMENT "HRAM" : FAR
.SEGMENT "HRAM2" : FAR
.SEGMENT "HDATA" : FAR
.SEGMENT "XCODE"

.SEGMENT "CODE"

start:
        jmp init_snes
main:

        .a8
        .i16
        .smart


        ; 
        ; set BG properties
        ;

        ;ldx BG_MAP_ADDR($0000)
        ldx #$0000
        stx BG1SC
        ldx #($800>>BG_MAP_SHIFT)
        stx BG2SC
        ldx #($1000>>BG1_CHR_SHIFT | $4000>>BG2_CHR_SHIFT)
        stx BG12NBA

        ;
        ; copy font & cgram data
        ;

        ldx #$1000
        stx VMADDL
        ldx #.LOWORD(bg_even_tiles_dma)
        jsr g_dma_transfer

        ldx #$4000
        stx VMADDL
        ldx #.LOWORD(bg_odd_tiles_dma)
        jsr g_dma_transfer

        ldx #$0000
        stx VMADDL
        ldx #.LOWORD(bg_even_map_dma)
        jsr g_dma_transfer

        ldx #$800
        stx VMADDL
        ldx #.LOWORD(bg_odd_map_dma)
        jsr g_dma_transfer

        lda #$00
        sta $2121
        ldx #.LOWORD(bg_even_pal_dma)
        jsr g_dma_transfer


        ;
        ; config & enable display
        ;

        lda #(1<<3)
        sta SETINI


        lda #$01
        sta BGMODE

        lda #(1<<1)               ;
        sta TM                    ; BG2 = main screen

        lda #(1<<0)               ;
        sta TS                    ; BG1 = sub screen

        lda #$0f
        sta INIDISP

        ;
        ; enable NMI/joypad reading
        ;

        lda #$81
        sta $4200
        cli

main_loop: 
        jmp main_loop

quit:


brk_handler:
        bra brk_handler
irq_handler:
        bra irq_handler


nmi:

        phb
        pha
        phx
        phy
        phd

        pld
        ply
        plx
        pla
        plb

        rti


;
; dma transfers
;

bg_even_tiles_dma: build_dma_tag 1,$18,.loword(bg_even_tiles),^bg_even_tiles,18592
bg_odd_tiles_dma:  build_dma_tag 1,$18,.loword(bg_odd_tiles),^bg_odd_tiles,18624
bg_even_map_dma:   build_dma_tag 1,$18,.loword(bg_even_map),^bg_even_map,1792
bg_odd_map_dma:    build_dma_tag 1,$18,.loword(bg_odd_map),^bg_odd_map,1792
bg_even_pal_dma:   build_dma_tag 0,$22,.loword(bg_even_pal),^bg_even_pal,bg_even_pal_end-bg_even_pal

.SEGMENT "GRAPHICS"

.include "bg_odd.gfx"
.include "bg_even.gfx"
