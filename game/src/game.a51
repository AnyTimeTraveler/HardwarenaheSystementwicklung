NAME game

SEG_MAIN SEGMENT CODE

EXTRN CODE (DAT_LEVEL_TICKS, DAT_TETRIS_PIECES, PFUN_SETUP_TIMERS)
EXTRN DATA (SCREEN_REFRESH_CURRENT_ROW, CURRENT_PIECE_INDEX)
EXTRN DATA (CURRENT_PIECE_ROT_INDEX, CURRENT_PIECE_V_POS, CURRENT_PIECE_H_POS)
EXTRN DATA (CP, GAMETICK_SUB_COUNTER, CURRENT_LEVEL, CURRENT_PIECE_DECOMPRESSED)
EXTRN IDATA (GAMESCREEN, STACK)
PUBLIC PJMP_MAIN

; Main
RSEG SEG_MAIN
PJMP_MAIN:
    ; move stack to the indirect addressed area, so the other register banks are free
    ; normally, the stack starts at 0x07, which is the start of the second register bank
    MOV SP, #STACK
    CALL PFUN_SETUP_TIMERS
    ; Reset the screen driver row
    MOV SCREEN_REFRESH_CURRENT_ROW, #0
    ; CALL PFUN_DETECT_BAUDRATE
    MOV CURRENT_PIECE_INDEX, #1
    MOV CURRENT_PIECE_ROT_INDEX, #1
    CALL FUN_DECOMPRESS_PIECE
    MOV CURRENT_PIECE_V_POS, #0
LOOP_MAIN:
    JMP LOOP_MAIN

FUN_DECOMPRESS_PIECE:
    ; load compressed piece into R1 and R2
    MOV DPTR, #DAT_TETRIS_PIECES
    MOV A, CURRENT_PIECE_INDEX
    MOV B, #8
    MUL AB
    ADD A, CURRENT_PIECE_ROT_INDEX
    ADD A, CURRENT_PIECE_ROT_INDEX
    MOV R1, A
    MOVC A, @A + DPTR
    XCH A, R1
    INC A
    MOVC A, @A + DPTR
    MOV R2, A
    ; Overwrite the decompressed piece
    ; first nibble of byte 0
    MOV CP_R0_L, #0
    MOV CP_R0_R, R1
    ANL CP_R0_R, #0xF0
    ; second nibble of byte 1
    MOV CP_R1_L, #0
    MOV A, R1
    SWAP A
    ANL A, #0xF0
    MOV CP_R1_R, A
    ; first nibble of byte 1
    MOV CP_R2_L, #0
    MOV CP_R2_R, R2
    ANL CP_R2_R, #0xF0
    ; second nibble of byte 1
    MOV CP_R3_L, #0
    MOV A, R2
    SWAP A
    ANL A, #0xF0
    MOV CP_R3_R, A
    RET

EXTRN DATA (CP_R0_L, CP_R0_R, CP_R1_L, CP_R1_R, CP_R2_L, CP_R2_R, CP_R3_L, CP_R3_R)

MOVE_ROW_LEFT MACRO ROW
CLR C
MOV A, ROW&_R
RLC A
MOV ROW&_R, A
MOV A, ROW&_L
RLC A
MOV ROW&_L, A
ENDM

MOVE_ROW_RIGHT MACRO ROW
CLR C
MOV A, ROW&_L
RRC A
MOV ROW&_L, A
MOV A, ROW&_R
RRC A
MOV ROW&_R, A
ENDM

FUN_SHIFT_PIECE_LEFT:
    MOVE_ROW_LEFT CP_R0
    MOVE_ROW_LEFT CP_R1
    MOVE_ROW_LEFT CP_R2
    MOVE_ROW_LEFT CP_R3
    RET

FUN_SHIFT_PIECE_RIGHT:
    MOVE_ROW_RIGHT CP_R0
    MOVE_ROW_RIGHT CP_R1
    MOVE_ROW_RIGHT CP_R2
    MOVE_ROW_RIGHT CP_R3
    RET

FUN_ADD_PIECE:
    ; move to current piece location
    MOV A, #GAMESCREEN
    ADD A, CURRENT_PIECE_V_POS
    ADD A, CURRENT_PIECE_V_POS
    MOV R1, A
    ; load current piece address
    MOV R0, #CURRENT_PIECE_DECOMPRESSED
    REPT 8
    ; load current piece byte
    MOV A, @R0
    ; or it with the gamescreen to insert it
    ORL A, @R1
    ; write back to gamescreen
    MOV @R1, A
    ; increment both adresses
    INC R1
    INC R0
    ENDM
    RET

FUN_REMOVE_PIECE:
    ; move to current piece location
    MOV A, #GAMESCREEN
    ADD A, CURRENT_PIECE_V_POS
    ADD A, CURRENT_PIECE_V_POS
    MOV R1, A
    ; load current piece address
    MOV R0, #CURRENT_PIECE_DECOMPRESSED
    ; for each byte of the current piece
    REPT 8
    ; load current piece byte
    MOV A, @R0
    ; invert byte
    XRL A, 0xFF
    ; logical and to cut out the piece
    ANL A, @R1
    ; write back to gamescreen
    MOV @R1, A
    ; increment both adresses
    INC R1
    INC R0
    ENDM
    RET

FUN_CHECK_COLLISION:
    MOV A, #GAMESCREEN
    ADD A, CURRENT_PIECE_V_POS
    ADD A, CURRENT_PIECE_V_POS
    MOV R1, A
    MOV R0, #CP
    REPT 8
    MOV A, @R0
    XRL A, 0xFF
    ANL A, @R1
    MOV @R1, A
    INC R1
    INC R0
    ENDM
    RET

FUN_CLEAR_FULL_ROWS:
    RET

FUN_MOVE_ROWS_DOWN:
    RET

SEG_GAMETICK SEGMENT CODE

PUBLIC PJMPI_SUB_GAMETICK

RSEG SEG_GAMETICK
PJMPI_SUB_GAMETICK:
    ; Reload with DF76
    ; for 200 Interrupts per Second
    ; Actually, reload with D20C
    ; for one tick every 7 ms (one gametick on lv 15) and scale from there
    CLR TR1
    MOV TH1, #0xDF
    MOV TL1, #0x76
    SETB TR1

    ; increment gametick subcounter
    MOV A, GAMETICK_SUB_COUNTER
    DEC A
    MOV GAMETICK_SUB_COUNTER, A
    ; check if sub counter has been reached
    JNZ SUB_GAMETICK_RETURN
    
    ; load max ticks for current level
    MOV DPTR, #DAT_LEVEL_TICKS
    MOV A, CURRENT_LEVEL
    MOVC A, @A+DPTR
    MOV GAMETICK_SUB_COUNTER, A
    
    CALL FUN_GAMETICK

SUB_GAMETICK_RETURN:
    RETI

FUN_GAMETICK:
    CALL FUN_REMOVE_PIECE
    ; CALL FUN_SHIFT_PIECE_LEFT
    INC CURRENT_PIECE_V_POS
    CALL FUN_ADD_PIECE
GAMETICK_RETURN:
    RET
END
