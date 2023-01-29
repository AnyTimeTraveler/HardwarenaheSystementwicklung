NAME screen

SEG_REFRESH_SCREEN SEGMENT CODE

EXTRN DATA (SCREEN_REFRESH_CURRENT_ROW)
EXTRN IDATA (GAMESCREEN_0, GAMESCREEN_1, GAMESCREEN_2)
EXTRN XDATA (LED_MATRIX_0, LED_MATRIX_1, LED_MATRIX_2)
EXTRN CODE (PFUN_SERIAL_WRITE)
EXTRN BIT (OUT_SCREEN)
PUBLIC PJMPI_REFRESH_SCREEN

RSEG SEG_REFRESH_SCREEN
PJMPI_REFRESH_SCREEN:
    SETB OUT_SCREEN
    ; Software reload
    MOV TL0, #0x48
    MOV TH0, #0xF4

    MOV R7, SCREEN_REFRESH_CURRENT_ROW
    CALL FUN_REFRESH_SCREEN_ROW
    INC R7
    CJNE R7, #8, RETURN
    MOV R7, #0
RETURN:
    MOV SCREEN_REFRESH_CURRENT_ROW, R7
    ; Keine Instruktion. Der Assembler muss auch wissen,
    ; dass ab hier die Registerbank 0 verwendet wird.
    CLR OUT_SCREEN
    RETI


DRAW_SEGMENT MACRO OFFSET
    MOV R1, #GAMESCREEN_0 + OFFSET
    MOV R0, #GAMESCREEN_1 + OFFSET
    CALL FUN_REFRESH_MODULE
ENDM

; Send a new batch of data to each segment
; PARAM R7 Current line (preserved)
FUN_REFRESH_SCREEN_ROW:
    ; make current line into bitmask
    ; R1 tracks the required rotations + 1
    ; since we only have do-while loops available
    ; the first loop iteration only shifts the bit form carry into the byte
    ; line is equivalent to MOV R1, R7
    MOV A, R7
    MOV R1, A
    INC R1
    ; by shifting through carry and setting carry to 1
    ; we can shift once and end up with what would have been zero shifts
    SETB C
    MOV A, #0
RFS_SHIFT:
    RLC A
    DJNZ R1, RFS_SHIFT
    MOV R6, A
RFS_SHIFT_DONE:
    MOV DPTR, #LED_MATRIX_0
    DRAW_SEGMENT 0
    DRAW_SEGMENT 16
    DRAW_SEGMENT 32
    DRAW_SEGMENT 48
    DRAW_SEGMENT 1
    DRAW_SEGMENT 17
    DRAW_SEGMENT 33
    DRAW_SEGMENT 49
    RET

; RARAM R1 Gamescreen
; PARAM R6 Row-Bitmask
; PARAM R7 Current line (preserved)
FUN_REFRESH_MODULE:
    MOV R5, #8
RF_LOOP:
    ; check if there is a pixel
    MOV A, @R1
    ANL A, R6
    JZ PIXEL_OFF
PIXEL_ON:
    MOV A, @R0
    ANL A, R6
    JZ GREEN
RED:
    MOV A, #0x0F
    JMP RF_WRITE
GREEN:
    MOV A, #0xF0
    JMP RF_WRITE
PIXEL_OFF:
    MOV A, #0x00
RF_WRITE:
    MOVX @DPTR, A
    INC R1
    INC R1
    INC R0
    INC R0
    INC DPTR
    DJNZ R5, RF_LOOP
    MOV A, R7
    ORL A, #0x08
    MOVX @DPTR, A
    INC DPTR
    RET

END
