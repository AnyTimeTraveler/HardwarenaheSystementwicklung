NAME gamedata

; =========================
; == Tetris Level Speeds ==
; =========================

SEG_LEVEL_TICKS SEGMENT CODE

PUBLIC DAT_LEVEL_TICKS

RSEG SEG_LEVEL_TICKS
DAT_LEVEL_TICKS:
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
PUBLIC DAT_TETRIS_PIECES, PIECE_LEN

RSEG SEG_PIECES
DAT_TETRIS_PIECES:
; P0 : Line
P_LINE_000:         DW 0x4444
P_LINE_090:         DW 0x00F0
P_LINE_180:         DW 0x4444
P_LINE_270:         DW 0x00F0
; P1 : Bump
P_BUMP_000:         DW 0x04E0
P_BUMP_090:         DW 0x0464
P_BUMP_180:         DW 0x00E4
P_BUMP_270:         DW 0x04C4
; P2 : L
P_L_000:            DW 0x44C0
P_L_090:            DW 0x8E00
P_L_180:            DW 0x6440
P_L_270:            DW 0x0E20
; P3 : L (reversed)
P_L_REV_000:        DW 0x4460
P_L_REV_090:        DW 0x0E80
P_L_REV_180:        DW 0xC440
P_L_REV_270:        DW 0x8E00
; P4 : Box
P_BOX_000:          DW 0xCC00
P_BOX_090:          DW 0xCC00
P_BOX_180:          DW 0xCC00
P_BOX_270:          DW 0xCC00
; P5 : Snake
P_SNAKE_000:        DW 0x2640
P_SNAKE_090:        DW 0x0C60
P_SNAKE_180:        DW 0x4C80
P_SNAKE_270:        DW 0x0C60
; P6 : Snake (reversed)
P_SNAME_REV_000:    DW 0x8C40
P_SNAME_REV_090:    DW 0x6C00
P_SNAME_REV_180:    DW 0x8C40
P_SNAME_REV_270:    DW 0x6C00
; P7 : Empty
; P_LINE_000:     DW 0x0000
; P_LINE_090:     DW 0x0000
; P_LINE_180:     DW 0x0000
; P_LINE_270:     DW 0x0000

PIECE_LEN           EQU 8

END
