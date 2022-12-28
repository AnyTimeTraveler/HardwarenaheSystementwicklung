NAME game

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
FUN_MAIN                    EQU 0x0033


; =============
; == INT RAM ==
; =============

REGISTER_BANKS_BEGIN        EQU 0x00
R0_ADDR                     EQU 0x00
R1_ADDR                     EQU 0x01
REGISTER_BANKS_END          EQU 0x20
REGISTER_BANKS_LEN          EQU 0x20

BIT_ADDRESSABLE_BEGIN       EQU 0x20

BIT_DO_REFRESH              EQU 0x20.1

BIT_ADDRESSABLE_END         EQU 0x30
BIT_ADDRESSABLE_LEN         EQU 0x10

SCRATCHPAD_BEGIN            EQU 0x30
SCRATCHPAD_END              EQU 0x80
SCRATCHPAD_LEN              EQU 0x50

MAP_BEGIN                   EQU 0x80
MAP_END                     EQU 0xC0
MAP_LEN                     EQU 0x40

STACK_BEGIN                 EQU 0xC0
STACK_END                   EQU 0xFF
STACK_LEN                   EQU 0x40


; =============
; == EXT RAM ==
; =============

RAM_START                   EQU 0x0000
RAW_DISPLAY_BUFFER_START    EQU 0x0000
RAW_DISPLAY_BUFFER_LINE_0   EQU 0x0000
RAW_DISPLAY_BUFFER_LINE_1   EQU 0x0100
RAW_DISPLAY_BUFFER_LINE_2   EQU 0x0200
RAW_DISPLAY_BUFFER_LINE_3   EQU 0x0300
RAW_DISPLAY_BUFFER_LINE_4   EQU 0x0400
RAW_DISPLAY_BUFFER_LINE_5   EQU 0x0500
RAW_DISPLAY_BUFFER_LINE_6   EQU 0x0600
RAW_DISPLAY_BUFFER_LINE_7   EQU 0x0700
RAW_DISPLAY_BUFFER_END      EQU 0x0800
GAME_SCREEN_START           EQU 0x0800
GAME_SCREEN_END             EQU 0x1000
RAM_END                     EQU 0x2000


LED_MATRIX_START            EQU 0x2000
LED_MATRIX_END              EQU 0x2100
LED_MATRIX_ROW_LEN          EQU 0x9
LED_MATRIX_LEN              EQU 0x48
LED_MATRIX_ADDR_SPACE_LEN   EQU 0x100


; ==========
; == CODE ==
; ==========

CSEG AT ISR_RESET
    JMP FUN_MAIN

$INCLUDE(screen_refresh.a51)

; Main
CSEG AT FUN_MAIN
    CALL FUN_SETUP_TIMER_0
    CALL FUN_CLEAR_SCREEN_MEMORY
    MOV R1, #0
LOOP_MAIN:
    SETB P3.5
    JBC BIT_DO_REFRESH, JMP_REFRESH_SCREEN
    JMP LOOP_MAIN


FUN_CLEAR_SCREEN_MEMORY:
    MOV DPTR, #LED_MATRIX_START
    MOV A, #0x0F
    REPT 8
    REPT 8
        MOVX @DPTR, A
        REPT 7
            INC DPL
            MOVX @DPTR, A
        ENDM
        ; Skip enable line
        INC DPTR
    ENDM
    ENDM
    RET

; =================
; == SCREEN DATA ==
; =================

END
