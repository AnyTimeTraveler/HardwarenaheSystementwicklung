NAME screen

$INCLUDE(constants.a51)


CSEG AT ISR_TIMER_0
    ; Wechsel auf die Registerbank 2
    SETB RS1
    ; Keine Instruktion. Der Assembler muss auch wissen,
    ; dass ab hier die Registerbank 2 verwendet wird.
    USING 2
    ; CLR TR0
    MOV TH0, #0xF4
    MOV TL0, #0x48
    ; SETB TR0
    CALL SEG_REFRESH_SCREEN
    ; Wechsel auf die Registerbank 0
    CLR RS1
    ; Keine Instruktion. Der Assembler muss auch wissen,
    ; dass ab hier die Registerbank 0 verwendet wird.
    USING 0
    RETI

CSEG AT SEG_REFRESH_SCREEN
FUN_REFRESH_SCREEN:
    MOV R7, SCREEN_REFRESH_CURRENT_ROW
    CALL FUN_REFRESH_SCREEN_ROW
    INC R7
    CJNE R7, #8, RETURN
    MOV R7, #0
RETURN:
    MOV SCREEN_REFRESH_CURRENT_ROW, R7
    RET

; Send a new batch of data to each segment
; PARAM R7 Current line (preserved)
FUN_REFRESH_SCREEN_ROW:
    ; make current line into bitmask
    ; R1 tracks the required rotations + 1
    ; since we only have do-while loops available
    ; the first loop iteration only shifts the bit form carry into the byte
    ; line is equivalent to MOV R1, R7
    MOV REGISTER_BANK_2_BEGIN + 1, R7
    INC R1
    ; by shifting through carry and setting carry to 1
    ; we can shift once and end up with what would have been zero shifts
    SETB C
    MOV A, #0
RFS_SHIFT:
    RRC A
    DJNZ R1, RFS_SHIFT
    MOV R6, A
RFS_SHIFT_DONE:
    MOV DPTR, #LED_MATRIX_0_START
    MOV R1, #GAMESCREEN_BEGIN + 1
    CALL FUN_REFRESH_MODULE
    MOV R1, #GAMESCREEN_BEGIN + 17
    CALL FUN_REFRESH_MODULE
    MOV R1, #GAMESCREEN_BEGIN + 33
    CALL FUN_REFRESH_MODULE
    MOV R1, #GAMESCREEN_BEGIN + 49
    CALL FUN_REFRESH_MODULE
    MOV R1, #GAMESCREEN_BEGIN + 0
    CALL FUN_REFRESH_MODULE
    MOV R1, #GAMESCREEN_BEGIN + 16
    CALL FUN_REFRESH_MODULE
    MOV R1, #GAMESCREEN_BEGIN + 32
    CALL FUN_REFRESH_MODULE
    MOV R1, #GAMESCREEN_BEGIN + 48
    CALL FUN_REFRESH_MODULE
    RET


; RARAM R1 Gamescreen
; PARAM R6 Row-Bitmask
; PARAM R7 Current line (preserved)
FUN_REFRESH_MODULE:
    MOV R5, #8
RF_LOOP:
    MOV A, @R1
    ANL A, R6
    JZ PIXEL_OFF
    MOV A, #0x0F
    JMP RF_WRITE
PIXEL_OFF:
    MOV A, #0x00
RF_WRITE:
    MOVX @DPTR, A
    INC R1
    INC R1
    INC DPTR
    DJNZ R5, RF_LOOP
    MOV A, R7
    ORL A, #0x08
    MOVX @DPTR, A
    INC DPTR
    RET







END
