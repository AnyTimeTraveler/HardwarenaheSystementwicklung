NAME allocations_idata

; =============
; == INT RAM ==
; =============

; BEGIN Register
PUBLIC REGISTER_BANK_0_BEGIN, REGISTER_BANK_1_BEGIN, REGISTER_BANK_2_BEGIN, REGISTER_BANK_3_BEGIN

REGISTER_BANK_0_BEGIN       DATA 0x00
REGISTER_BANK_1_BEGIN       DATA 0x08
REGISTER_BANK_2_BEGIN       DATA 0x10
REGISTER_BANK_3_BEGIN       DATA 0x18
; END Register

; BEGIN Bit Addressable
PUBLIC CURRENT_PIECE_DECOMPRESSED, CP, CP_R0_L, CP_R0_R, CP_R1_L, CP_R1_R, CP_R2_L, CP_R2_R, CP_R3_L, CP_R3_R
PUBLIC BIT_MOVE_LEFT, BIT_MOVE_RIGHT, BIT_MOVE_DOWN, BIT_MOVE_ROTATE_LEFT, BIT_MOVE_ROTATE_RIGHT, BIT_PIECE_ON_BOARD, BIT_KEYBOARD_BREAK, BIT_CURRENT_COLOR

CURRENT_PIECE_DECOMPRESSED  DATA 0x20 ; length 8
CP                          DATA 0x20
CP_R0_L                     DATA 0x20
CP_R0_R                     DATA 0x21
CP_R1_L                     DATA 0x22
CP_R1_R                     DATA 0x23
CP_R2_L                     DATA 0x24
CP_R2_R                     DATA 0x25
CP_R3_L                     DATA 0x26
CP_R3_R                     DATA 0x27
CURRENT_PIECE_LENGTH        EQU  0x08

BSEG AT 0x20
CP_R0_L_B:                  DBIT 8
CP_R0_R_B:                  DBIT 8
CP_R1_L_B:                  DBIT 8
CP_R1_R_B:                  DBIT 8
CP_R2_L_B:                  DBIT 8
CP_R2_R_B:                  DBIT 8
CP_R3_L_B:                  DBIT 8
CP_R3_R_B:                  DBIT 8
BIT_MOVE_LEFT:              DBIT 1
BIT_MOVE_RIGHT:             DBIT 1
BIT_MOVE_DOWN:              DBIT 1
BIT_MOVE_ROTATE_LEFT:       DBIT 1
BIT_MOVE_ROTATE_RIGHT:      DBIT 1
BIT_PIECE_ON_BOARD:         DBIT 1
BIT_KEYBOARD_BREAK:         DBIT 1
BIT_CURRENT_COLOR:          DBIT 1
; END Bit Addressable

; BEGIN Internal RAM
PUBLIC GAMETICK_SUB_COUNTER, CURRENT_LEVEL, CURRENT_PIECE_INDEX, CURRENT_PIECE_ROT_INDEX, CURRENT_PIECE_V_POS, CURRENT_PIECE_H_POS, SCREEN_REFRESH_CURRENT_ROW, KEYBOARD_TIMER_RELOAD

DSEG AT 0x30
GAMETICK_SUB_COUNTER:       DS 1
CURRENT_LEVEL:              DS 1
CURRENT_PIECE_INDEX:        DS 1
CURRENT_PIECE_ROT_INDEX:    DS 1
CURRENT_PIECE_V_POS:        DS 1
CURRENT_PIECE_H_POS:        DS 1
SCREEN_REFRESH_CURRENT_ROW: DS 1
KEYBOARD_BIT_COUNT:         DS 1
KEYBOARD_INPUT_BYTE:        DS 1
KEYBOARD_TIMER_RELOAD:      DS 1
; BLINK_COUNTER:              DS 1

PUBLIC T2CON, T2MOD, RCAP2L, RCAP2H, TL2, TH2, LED

T2CON                       DATA 0xC8
T2MOD                       DATA 0xC9
RCAP2L                      DATA 0xCA
RCAP2H                      DATA 0xCB
TL2                         DATA 0xCC
TH2                         DATA 0xCD
LED                         BIT P3.5

PUBLIC GAMESCREEN, GAMESCREEN_END, GAMESCREEN_ROW_LEN, COLOURMAP, STACK

GAMESCREEN_END              DATA GAMESCREEN + 0x3F

ISEG AT 0x60
GAMESCREEN:                 DS 0x40
GAMESCREEN_ROW_LEN          EQU 0x04
COLOURMAP:                  DS 0x40
STACK:                      DS 0x20
; END Internal RAM

END
