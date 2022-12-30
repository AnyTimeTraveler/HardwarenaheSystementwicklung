NAME game

SEG_MAIN SEGMENT CODE

EXTRN CODE (DAT_LEVEL_TICKS, DAT_TETRIS_PIECES, PFUN_SETUP_TIMER_0)
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
    CALL PFUN_SETUP_TIMER_0
    ; Reset the screen driver row
    MOV SCREEN_REFRESH_CURRENT_ROW, #0
    ; CALL PFUN_DETECT_BAUDRATE
    MOV CURRENT_PIECE_INDEX, #0
    MOV CURRENT_PIECE_ROT_INDEX, #0
    CALL FUN_DECOMPRESS_PIECE
    MOV CURRENT_PIECE_V_POS, #0
    CALL FUN_ADD_PIECE
    MOV CURRENT_PIECE_V_POS, #4
    CALL FUN_ADD_PIECE
    MOV CURRENT_PIECE_INDEX, #5
    MOV CURRENT_PIECE_ROT_INDEX, #0
    CALL FUN_DECOMPRESS_PIECE
    MOV CURRENT_PIECE_V_POS, #16
    CALL FUN_ADD_PIECE
LOOP_MAIN:
    JMP LOOP_MAIN

FUN_DECOMPRESS_PIECE:
    ; load compressed piece into R1 and R2
    MOV DPTR, #DAT_TETRIS_PIECES
    MOV A, CURRENT_PIECE_INDEX
    MOV B, #4
    MUL AB
    ADD A, CURRENT_PIECE_ROT_INDEX
    MOV R1, A
    MOVC A, @A + DPTR
    XCH A, R1
    INC A
    MOVC A, @A + DPTR
    MOV R2, A
    ; Overwrite the decompressed piece
    ; row 0
    MOV CP + 0, #0
    ; first nibble of byte 0
    MOV A, R1
    MOV CP + 1, A
    ANL CP + 1, #0xF0
    ; row 1
    MOV CP + 2, #0
    ; second nibble of byte 1
    SWAP A
    MOV CP + 3, A
    ANL CP + 3, #0xF0
    ; row 2
    MOV CP + 4, #0
    ; first nibble of byte 1
    MOV A, R2
    MOV CP + 5, A
    ANL CP + 5, #0xF0
    ; row 3
    MOV CP + 6, #0
    ; second nibble of byte 1
    SWAP A
    MOV CP + 7, A
    ANL CP + 7, #0xF0
    RET

FUN_SHIFT_PIECE_LEFT:
    MOV R1, #CURRENT_PIECE_DECOMPRESSED + 7
ROT_L_BEGIN:
    CLR C
    MOV A, @R1
    RLC A
    MOV @R1, A
    DEC R1
    MOV A, @R1
    RLC A
    MOV @R1, A
    DEC R1
    CJNE R1, #CURRENT_PIECE_DECOMPRESSED - 1, ROT_L_BEGIN
    RET

FUN_SHIFT_PIECE_RIGHT:
    MOV R1, #CURRENT_PIECE_DECOMPRESSED
ROT_R_BEGIN:
    CLR C
    MOV A, @R1
    RRC A
    MOV @R1, A
    INC R1
    MOV A, @R1
    RRC A
    MOV @R1, A
    INC R1
    CJNE R1, #CURRENT_PIECE_DECOMPRESSED + 8, ROT_R_BEGIN
    RET

FUN_ADD_PIECE:
    MOV A, #GAMESCREEN
    ADD A, CURRENT_PIECE_V_POS
    MOV R1, A
    MOV R0, #CP
    REPT 8
    MOV A, @R0
    ORL A, @R1
    MOV @R1, A
    INC R1
    INC R0
    ENDM
    RET

FUN_REMOVE_PIECE:
    MOV A, #GAMESCREEN
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

FUN_CHECK_COLLISION:
    MOV A, #GAMESCREEN
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
    ; CLR TR1
    MOV TH1, #0xDF
    MOV TL1, #0x76
    ; SETB TR1

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
GAMETICK_RETURN:
    RET
END
