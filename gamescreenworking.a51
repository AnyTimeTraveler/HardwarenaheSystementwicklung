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
REGISTER_BANKS_END          EQU 0x20
REGISTER_BANKS_LEN          EQU 0x20

BIT_ADDRESSABLE_BEGIN       EQU 0x20

BIT_DO_REFRESH              EQU 0x20.1

BIT_ADDRESSABLE_END         EQU 0x30
BIT_ADDRESSABLE_LEN         EQU 0x10

SCRATCHPAD_BEGIN            EQU 0x30
SCRATCHPAD_END              EQU 0x80
SCRATCHPAD_LEN              EQU 0x50

RESERVED_BEGIN              EQU 0x80
RESERVED_END                EQU 0xC0
RESERVED_LEN                EQU 0x40

STACK_BEGIN                 EQU 0xC0
STACK_END                   EQU 0xFF
STACK_LEN                   EQU 0x40


; =============
; == EXT RAM ==
; =============



LED_MATRIX_START            EQU 0x2000
LED_MATRIX_START_HIGH       EQU 0x20
LED_MATRIX_START_LOW        EQU 0x00
LED_MATRIX_END              EQU 0x2100
LED_MATRIX_ROW_LEN          EQU 0x9
LED_MATRIX_LEN              EQU 0x48
LED_MATRIX_ADDR_SPACE_LEN   EQU 0x100
				       			           
LED_MAGICAL_COPY_START      EQU 0x6000
LED_MAGICAL_COPY_START_HIGH EQU 0x60
LED_MAGICAL_COPY_START_LOW  EQU 0x00


; ==========
; == CODE ==
; ==========

CSEG AT ISR_RESET
    JMP FUN_MAIN


CSEG AT ISR_TIMER_0
    CLR TR0
    MOV TL0, #0x54
    MOV TH0, #0xF2
    SETB TR0
    SETB BIT_DO_REFRESH
    RETI

; Main
CSEG AT FUN_MAIN
    CALL FUN_SETUP_TIMER_0
    CALL FUN_CLEAR_SCREEN_MEMORY
    MOV R1, #0
LOOP_MAIN:
    CLR P3.5
    JBC BIT_DO_REFRESH, JMP_REFRESH_SCREEN
    JMP LOOP_MAIN

FUN_SETUP_TIMER_0:
    ; Timer 1 $ Timer 0
    ; MODE BITS
    ; GATE | Counter/Timer | Mode 1 | Mode 0
    ; 
    ; Mode 00: 13 Bit Timer, 5 Bit Prescaler
    ; Mode 01: 16 Bit Timer, 0 Bit Prescaler
    ; Mode 11: 2x 8 Bit Timer (separat)
    ; 
    MOV TMOD, #0001$0001b
    MOV TL0, #0xBA
    MOV TH0, #0xEF
    
    ; Interrupts allgemein aktivieren
    SETB EA
    
    ; Timer 0 Interrupt aktivieren
    SETB ET0
    
    ; Timer 0 Run aktivieren
    SETB TR0
    
    RET


JMP_REFRESH_SCREEN:
    SETB P3.5
    MOV DPH, #LED_MATRIX_START_HIGH
    MOV DPL, #LED_MATRIX_START_LOW
    MOV A, R1
    ORL A, #0x08
    MOV R0, A	        
    CALL FUN_REFRESH_SCREEN
    INC R1
    CJNE R1, #8, LOOP_MAIN
    MOV R1, #0
    JMP LOOP_MAIN


; PARAM R0: Line configuration bits
; PARAM DPTR: LED Matrix to refresh
FUN_REFRESH_SCREEN:
    REPT 8
        MOV A, #0xF0 
        REPT 8
            MOVX @DPTR, A
            INC DPTR
        ENDM
        ; Write enable line
        MOV A, R0
        MOVX @DPTR, A
        INC DPTR
    ENDM
    RET


FUN_CLEAR_SCREEN_MEMORY:
    MOV DPH, #LED_MATRIX_START_HIGH
    MOV DPL, #LED_MATRIX_START_LOW
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
