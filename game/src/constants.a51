
; =========
; == ROM ==
; =========

ISR_RESET                   EQU 0x0000
ISR_EXTERN_0                EQU 0x0003
ISR_TIMER_0                 EQU 0x000B
ISR_EXTERN_1                EQU 0x0013
ISR_TIMER_1                 EQU 0x001B
ISR_SERIAL                  EQU 0x0023
ISR_TIMER_2                 EQU 0x002B
SEG_ISR_EXT_0               EQU 0x0033
SEG_MAIN                    EQU 0x0040
SEG_DETECT_BAUDRATE         EQU 0x1600
SEG_REFRESH_SCREEN          EQU 0x1700
SEG_SETUP_TIMER_0           EQU 0x1800
CONST_PIECES                EQU 0x1900
ROM_LEN                     EQU 0x2000

; ============
; == PIECES ==
; ============

PIECE_LEN                   EQU 8

; 0 (0)
P_LINE_000                  EQU CONST_PIECES + (0 * PIECE_LEN) + 0
P_LINE_090                  EQU CONST_PIECES + (0 * PIECE_LEN) + 2
P_LINE_180                  EQU CONST_PIECES + (0 * PIECE_LEN) + 4
P_LINE_270                  EQU CONST_PIECES + (0 * PIECE_LEN) + 6

; 1 (4)
P_BUMP_000                  EQU CONST_PIECES + (1 * PIECE_LEN) + 0
P_BUMP_090                  EQU CONST_PIECES + (1 * PIECE_LEN) + 2
P_BUMP_180                  EQU CONST_PIECES + (1 * PIECE_LEN) + 4
P_BUMP_270                  EQU CONST_PIECES + (1 * PIECE_LEN) + 6

; 2 (8)
P_L_000                     EQU CONST_PIECES + (2 * PIECE_LEN) + 0
P_L_090                     EQU CONST_PIECES + (2 * PIECE_LEN) + 2
P_L_180                     EQU CONST_PIECES + (2 * PIECE_LEN) + 4
P_L_270                     EQU CONST_PIECES + (2 * PIECE_LEN) + 6

; 3 (12)
P_BOX_000                   EQU CONST_PIECES + (3 * PIECE_LEN) + 0
P_BOX_090                   EQU CONST_PIECES + (3 * PIECE_LEN) + 2
P_BOX_180                   EQU CONST_PIECES + (3 * PIECE_LEN) + 4
P_BOX_270                   EQU CONST_PIECES + (3 * PIECE_LEN) + 6

; 4 (16)
P_SNAKE_000                 EQU CONST_PIECES + (4 * PIECE_LEN) + 0
P_SNAKE_090                 EQU CONST_PIECES + (4 * PIECE_LEN) + 2
P_SNAKE_180                 EQU CONST_PIECES + (4 * PIECE_LEN) + 4
P_SNAKE_270                 EQU CONST_PIECES + (4 * PIECE_LEN) + 6

; 5 (20)
P_SNAKE_REV_000             EQU CONST_PIECES + (5 * PIECE_LEN) + 0
P_SNAKE_REV_090             EQU CONST_PIECES + (5 * PIECE_LEN) + 2
P_SNAKE_REV_180             EQU CONST_PIECES + (5 * PIECE_LEN) + 4
P_SNAKE_REV_270             EQU CONST_PIECES + (5 * PIECE_LEN) + 6

; 6 (24)
P_L_REV_000                 EQU CONST_PIECES + (6 * PIECE_LEN) + 0
P_L_REV_090                 EQU CONST_PIECES + (6 * PIECE_LEN) + 2
P_L_REV_180                 EQU CONST_PIECES + (6 * PIECE_LEN) + 4
P_L_REV_270                 EQU CONST_PIECES + (6 * PIECE_LEN) + 6

; 7 (28)
P_EMPTY_000                 EQU CONST_PIECES + (7 * PIECE_LEN) + 0
P_EMPTY_090                 EQU CONST_PIECES + (7 * PIECE_LEN) + 2
P_EMPTY_180                 EQU CONST_PIECES + (7 * PIECE_LEN) + 4
P_EMPTY_270                 EQU CONST_PIECES + (7 * PIECE_LEN) + 6

; =============
; == INT RAM ==
; =============

; BEGIN Register
REGISTER_BANKS_BEGIN        EQU 0x00
REGISTER_BANK_0_BEGIN       EQU 0x08
REGISTER_BANK_1_BEGIN       EQU 0x08
REGISTER_BANK_2_BEGIN       EQU 0x10
REGISTER_BANK_3_BEGIN       EQU 0x18
REGISTER_BANKS_END          EQU 0x20
REGISTER_BANKS_LEN          EQU 0x20
; END Register

; BEGIN Bit Addressable
; 0x00
BIT_ADDRESSABLE_BEGIN       EQU 0x20
BIT_BAUD_ERROR_FLAG         EQU 0x2F.7
BITS_GAMESCREEN             EQU 0x20
BIT_ADDRESSABLE_END         EQU 0x30
BIT_ADDRESSABLE_LEN         EQU 0x10
; 0x80
; END Bit Addressable

; BEGIN Scratchpad
SCRATCHPAD_BEGIN            EQU 0x30
COLLISION_SECTION           EQU 0x37    ; maybe not needed
CURRENT_PIECE_INDEX         EQU 0x38
CURRENT_PIECE_ROT_INDEX     EQU 0x39
CURRENT_PIECE_V_POS         EQU 0x3A
CURRENT_PIECE_H_POS         EQU 0x3B
SCREEN_REFRESH_CURRENT_ROW  EQU 0x3C
CURRENT_PIECE_DECOMPRESSED  EQU 0x58
CP                          EQU CURRENT_PIECE_DECOMPRESSED
SCRATCHPAD_END              EQU 0x60
SCRATCHPAD_LEN              EQU 0x30
; END Scratchpad

CP_R0_L                     EQU CURRENT_PIECE_DECOMPRESSED + 0
CP_R0_R                     EQU CURRENT_PIECE_DECOMPRESSED + 1
CP_R1_L                     EQU CURRENT_PIECE_DECOMPRESSED + 2
CP_R1_R                     EQU CURRENT_PIECE_DECOMPRESSED + 3
CP_R2_L                     EQU CURRENT_PIECE_DECOMPRESSED + 4
CP_R2_R                     EQU CURRENT_PIECE_DECOMPRESSED + 5
CP_R3_L                     EQU CURRENT_PIECE_DECOMPRESSED + 6
CP_R3_R                     EQU CURRENT_PIECE_DECOMPRESSED + 7

; BEGIN Gamescreen
GAMESCREEN_BEGIN            EQU 0x60
GAMESCREEN_END              EQU 0xA0
GAMESCREEN_LEN              EQU 0x40
GAMESCREEN_ROW_LEN          EQU 0x04
; END Gamescreen

; BEGIN Stack
STACK_BEGIN                 EQU 0xE0
STACK_END                   EQU 0xFF
STACK_LEN                   EQU 0x20
; END Stack


; =============
; == EXT RAM ==
; =============

XRAM_START                  EQU 0x0000
XRAM_END                    EQU 0x2000
XRAM_LEN                    EQU 0x2000

LED_MATRIX_0_START          EQU 0x2000
LED_MATRIX_0_END            EQU 0x2100
LED_MATRIX_0_ROW_LEN        EQU 0x9
LED_MATRIX_0_LEN            EQU 0x48
LED_MATRIX_0_ADDR_SPACE_LEN EQU 0x100

LED_MATRIX_1_START          EQU 0x2100
LED_MATRIX_1_END            EQU 0x2200
LED_MATRIX_1_ROW_LEN        EQU 0x9
LED_MATRIX_1_LEN            EQU 0x48
LED_MATRIX_1_ADDR_SPACE_LEN EQU 0x100

LED_MATRIX_2_START          EQU 0x2200
LED_MATRIX_2_END            EQU 0x2300
LED_MATRIX_2_ROW_LEN        EQU 0x9
LED_MATRIX_2_LEN            EQU 0x48
LED_MATRIX_2_ADDR_SPACE_LEN EQU 0x100
