CSEG AT ISR_TIMER_0
    CLR TR0
    MOV TL0, #0x54
    MOV TH0, #0xF2
    SETB TR0
    SETB BIT_DO_REFRESH
    RETI


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
    ; Interrupts allgemein aktivieren
    SETB EA
    ; Timer 0 Interrupt aktivieren
    SETB ET0
    ; Timer 0 Run aktivieren
    SETB TR0
    
    RET


JMP_REFRESH_SCREEN:
    CLR P3.5
    MOV DPTR, #LED_MATRIX_START
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
