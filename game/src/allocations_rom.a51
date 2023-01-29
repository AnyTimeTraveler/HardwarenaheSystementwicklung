NAME allocations_rom

; ==========
; == Logo ==
; ==========

SEG_LOGO SEGMENT CODE

PUBLIC DAT_LOGO

RSEG SEG_LOGO
DAT_LOGO:
    DW 0x0000
    DW 0x7E7C
    DW 0x1840
    DW 0x1840
    DW 0x1878
    DW 0x1840
    DW 0x1840
    DW 0x187C
    DW 0x0000
    DW 0x7E70
    DW 0x1848
    DW 0x1848
    DW 0x1870
    DW 0x1860
    DW 0x1850
    DW 0x1848
    DW 0x0000
    DW 0x1830
    DW 0x1840
    DW 0x1840
    DW 0x1830
    DW 0x1808
    DW 0x1808
    DW 0x1830
    DW 0x0000
    DW 0x0000
    DW 0x0000
    DW 0x0230
    DW 0x0608
    DW 0xA210
    DW 0xA220
    DW 0x42B8


; ===============
; == Gamestate ==
; ===============

PUBLIC GS_FIRST_RUN, GS_PRE_GAME, GS_PLAYING, GS_ROW_CLEARING, GS_LOST

GS_FIRST_RUN            EQU 0x00
GS_PRE_GAME             EQU 0x01
GS_PLAYING              EQU 0x02
GS_ROW_CLEARING         EQU 0x03
GS_LOST                 EQU 0x04


; ====================
; == Keyboard Codes ==
; ====================

PUBLIC KDB_EXTENDED, KDB_BREAK, KDB_KEY_LEFT_ARROW, KDB_KEY_RIGHT_ARROW, KDB_KEY_UP_ARROW, KDB_KEY_DOWN_ARROW, KDB_KEY_R

KDB_EXTENDED             EQU 0xE0
KDB_BREAK                EQU 0xF0
KDB_KEY_LEFT_ARROW       EQU 0x6B
KDB_KEY_RIGHT_ARROW      EQU 0x74
KDB_KEY_UP_ARROW         EQU 0x75
KDB_KEY_DOWN_ARROW       EQU 0x72
KDB_KEY_R                EQU 0x2D

; =========================
; == Tetris Level Speeds ==
; =========================

SEG_LEVEL_TICKS SEGMENT CODE

PUBLIC DAT_LEVEL_TICKS

RSEG SEG_LEVEL_TICKS
DAT_LEVEL_TICKS:
    DB 35           ; idle animation ticks ( = 250 ms per tick)
    DB 142
    DB 112
    DB 88
    DB 67
    DB 50
    DB 37
    DB 27
    DB 19
    DB 13
    DB 9
    DB 6
    DB 4
    DB 3
    DB 2
    DB 1


; ===================
; == Tetris Pieces ==
; ===================

SEG_PIECES SEGMENT CODE

PUBLIC P_LINE_000, P_LINE_090, P_LINE_180, P_LINE_270
PUBLIC P_BUMP_000, P_BUMP_090, P_BUMP_180, P_BUMP_270
PUBLIC P_L_000, P_L_090, P_L_180, P_L_270
PUBLIC P_L_REV_000, P_L_REV_090, P_L_REV_180, P_L_REV_270
PUBLIC P_BOX_000, P_BOX_090, P_BOX_180, P_BOX_270
PUBLIC P_SNAKE_000, P_SNAKE_090, P_SNAKE_180, P_SNAKE_270
PUBLIC P_SNAME_REV_000, P_SNAME_REV_090, P_SNAME_REV_180, P_SNAME_REV_270
PUBLIC DAT_TETRIS_PIECES, PIECE_SIZE

RSEG SEG_PIECES
DAT_TETRIS_PIECES:
; 0
P_LINE_000:         DW 0x4444
P_LINE_090:         DW 0x0F00
P_LINE_180:         DW 0x4444
P_LINE_270:         DW 0x0F00
; 1
P_BUMP_000:         DW 0x4E00
P_BUMP_090:         DW 0x4640
P_BUMP_180:         DW 0x0E40
P_BUMP_270:         DW 0x4C40
; 2
P_L_000:            DW 0x44C0
P_L_090:            DW 0x8E00
P_L_180:            DW 0x6440
P_L_270:            DW 0x0E20
; 3
P_L_REV_000:        DW 0x4460
P_L_REV_090:        DW 0x0E80
P_L_REV_180:        DW 0xC440
P_L_REV_270:        DW 0x8E00
; 4
P_SNAKE_000:        DW 0xC600
P_SNAKE_090:        DW 0x2640
P_SNAKE_180:        DW 0x0C60
P_SNAKE_270:        DW 0x8C40
; 5
P_SNAME_REV_000:    DW 0x6C00
P_SNAME_REV_090:    DW 0x4620
P_SNAME_REV_180:    DW 0x06C0
P_SNAME_REV_270:    DW 0x8C40
; 6
P_BOX_000:          DW 0xCC00
P_BOX_090:          DW 0xCC00
P_BOX_180:          DW 0xCC00
P_BOX_270:          DW 0xCC00
; 7
P_EMPTY_000:        DW 0x0000
P_EMPTY_090:        DW 0x0000
P_EMPTY_180:        DW 0x0000
P_EMPTY_270:        DW 0x0000

PIECE_SIZE          EQU 8

END
