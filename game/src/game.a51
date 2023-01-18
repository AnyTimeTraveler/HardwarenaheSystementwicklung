NAME game

SEG_MAIN SEGMENT CODE

EXTRN CODE (DAT_LEVEL_TICKS, DAT_TETRIS_PIECES, PFUN_SETUP_TIMERS, PFUN_DETECT_BAUDRATE)
EXTRN DATA (SCREEN_REFRESH_CURRENT_ROW, CURRENT_PIECE_INDEX)
EXTRN DATA (CURRENT_PIECE_ROT_INDEX, CURRENT_PIECE_V_POS, CURRENT_PIECE_H_POS)
EXTRN DATA (CP, GAMETICK_SUB_COUNTER, CURRENT_LEVEL, CURRENT_PIECE_DECOMPRESSED)
EXTRN IDATA (GAMESCREEN, STACK)
EXTRN DATA (PIECE_SIZE)
EXTRN BIT (LED)
PUBLIC PJMP_MAIN

RSEG SEG_MAIN
PJMP_MAIN:
    CLR LED
    ; move stack to the indirect addressed area, so the other register banks are free
    ; normally, the stack starts at 0x07, which is the start of the second register bank
    MOV SP, #STACK
    CALL PFUN_SETUP_TIMERS
    CALL FUN_CLEAR
    CALL PFUN_DETECT_BAUDRATE
    ; Activate timer 1 for gameticks
    CLR TR1
    CLR ET1  
    JMP $
    SETB TR1
    ; Reset the screen driver row
    MOV SCREEN_REFRESH_CURRENT_ROW, #0
    CALL FUN_DRAW_BACKGROUND
    ; Put first piece on the screen
    MOV CURRENT_PIECE_INDEX, #5
    MOV CURRENT_PIECE_ROT_INDEX, #0
    CALL FUN_DECOMPRESS_PIECE
    MOV CURRENT_PIECE_V_POS, #0
    CALL FUN_ADD_PIECE
LOOP_MAIN:
    JMP LOOP_MAIN


SEG_DECOMPRESS_PIECE SEGMENT CODE

RSEG SEG_DECOMPRESS_PIECE
FUN_DECOMPRESS_PIECE:
    ; load compressed piece into R1 and R2
    MOV DPTR, #DAT_TETRIS_PIECES
    ; add 8 * piece index to it,
    ; to skip to the start of the correct piece
    ; since each piece is 8 bytes
    MOV A, CURRENT_PIECE_INDEX
    MOV B, #PIECE_SIZE
    MUL AB
    ; add 2 * rotation, since every rotation is 2 bytes
    ADD A, CURRENT_PIECE_ROT_INDEX
    ADD A, CURRENT_PIECE_ROT_INDEX
    ; save address in R1
    MOV R1, A
    ; get byte
    MOVC A, @A + DPTR
    ; swap adress back into A
    XCH A, R1
    ; increment to get the second byte of the piece
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
    MOV CURRENT_PIECE_H_POS, #8
    RET


SEG_SHIFT_PIECE SEGMENT CODE

EXTRN DATA (CP_R0_L, CP_R0_R, CP_R1_L, CP_R1_R, CP_R2_L, CP_R2_R, CP_R3_L, CP_R3_R)

RSEG SEG_SHIFT_PIECE

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
    DEC CURRENT_PIECE_H_POS
    RET

FUN_SHIFT_PIECE_RIGHT:
    MOVE_ROW_RIGHT CP_R0
    MOVE_ROW_RIGHT CP_R1
    MOVE_ROW_RIGHT CP_R2
    MOVE_ROW_RIGHT CP_R3
    INC CURRENT_PIECE_H_POS
    RET

SEG_ROTATE_PIECE SEGMENT CODE

RSEG SEG_ROTATE_PIECE

FUN_ROTATE_PIECE_LEFT:
    ; make sure it stays a valid value
    MOV A, CURRENT_PIECE_ROT_INDEX
    JNZ DEC_ROT_INDEX
    ; since it also gets decremented, set it one higher
    MOV CURRENT_PIECE_ROT_INDEX, #4
DEC_ROT_INDEX:
    DEC CURRENT_PIECE_ROT_INDEX
    MOV R3, CURRENT_PIECE_H_POS
    ; load the new piece
    CALL FUN_DECOMPRESS_PIECE
    ; shift it to the correct place
    JMP FUN_MOVE_TO_CORRECT_SHIFT

FUN_ROTATE_PIECE_RIGHT:
    ; make sure it stays a valid value
    MOV A, CURRENT_PIECE_ROT_INDEX
    CJNE A, #3, INC_ROT_INDEX
    ; since it also gets incremented, set it one lower
    MOV CURRENT_PIECE_ROT_INDEX, #255
INC_ROT_INDEX:
    INC CURRENT_PIECE_ROT_INDEX
    MOV R3, CURRENT_PIECE_H_POS
    ; load the new piece
    CALL FUN_DECOMPRESS_PIECE
    ; shift it to the correct place

FUN_MOVE_TO_CORRECT_SHIFT:
    MOV A, R3
    CLR C
    SUBB A, #8
    JC SMALLER
    JNZ LARGER
EQUAL:
    JMP ROT_LEFT_DONE
LARGER:
    CALL FUN_SHIFT_PIECE_RIGHT
    MOV A, R3
    CJNE A, CURRENT_PIECE_H_POS, LARGER
    JMP ROT_LEFT_DONE
SMALLER:
    CALL FUN_SHIFT_PIECE_LEFT
    MOV A, R3
    CJNE A, CURRENT_PIECE_H_POS, SMALLER
ROT_LEFT_DONE:
    RET

SEG_ADD_REMOVE_PIECE SEGMENT CODE

EXTRN BIT (BIT_PIECE_ON_BOARD)

RSEG SEG_ADD_REMOVE_PIECE

FUN_ADD_PIECE:
    JB BIT_PIECE_ON_BOARD, AP_RET
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
    SETB BIT_PIECE_ON_BOARD
AP_RET:
    RET

FUN_REMOVE_PIECE:
    JNB BIT_PIECE_ON_BOARD, RP_RET
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
    XRL A, #0xFF
    ; logical and to cut out the piece
    ANL A, @R1
    ; write back to gamescreen
    MOV @R1, A
    ; increment both adresses
    INC R1
    INC R0
    ENDM
    CLR BIT_PIECE_ON_BOARD
RP_RET:
    RET


SEG_COLLISION SEGMENT CODE

RSEG SEG_COLLISION

; RETURN C if collision
FUN_CHECK_COLLISION:
    ; Calculate next gamescreen row
    MOV A, #GAMESCREEN
    ADD A, CURRENT_PIECE_V_POS
    ADD A, CURRENT_PIECE_V_POS
    ; Store row address in R1
    MOV R1, A
    MOV R0, #CURRENT_PIECE_DECOMPRESSED
    REPT 8
    MOV A, @R0
    ANL A, @R1
    JNZ OVERLAP
    INC R1
    INC R0
    ENDM
    CLR C
    RET
OVERLAP:
    SETB C
    RET

SEG_ROWS SEGMENT CODE

EXTRN DATA (GAMESCREEN_END, REGISTER_BANK_0_BEGIN)

RSEG SEG_ROWS

; RETURN C if there is a full row
; RETURN R1 address of full row, if any
FUN_FIND_FULL_ROW:
    ; start at the second to lowest line
    MOV R1, #GAMESCREEN_END - 2
    ; now R1 is at the 2nd byte of the lowest line
LINE_START:
    CJNE @R1, #0xFF, SKIP_TWO
    DEC R1
    CJNE @R1, #0xFF, SKIP_ONE
    ; full line has been found
    SETB C
    RET
SKIP_TWO:
    DEC R1
SKIP_ONE:
    DEC R1
    ; keep going until we're at the top line
    CJNE R1, #GAMESCREEN + 1, LINE_START
    CLR C
    RET


; PARAM R1 Row to clear (preserved)
FUN_CLEAR_ROW:
    MOV @R1, #0x80
    INC R1
    MOV @R1, #0x01
    DEC R1
    RET

; PARAM R1 Row to fill (preserved)
FUN_FILL_ROW:
    MOV @R1, #0xFF
    INC R1
    MOV @R1, #0xFF
    DEC R1
    RET

; PARAM R1 Row to fill first
FUN_MOVE_ROWS_DOWN:
    ; move R0 to the row above
    ; equivalent to MOV R0, R1
    MOV R0, REGISTER_BANK_0_BEGIN + 1
    INC R1
    DEC R0
MOVE_DOWN:
    MOV A, @R0
    MOV @R1, A
    DEC R0
    DEC R1
    CJNE R1, #GAMESCREEN + 1, MOVE_DOWN
    ; at the top row, draw the sides
    MOV @R1, #0x01
    DEC R1
    MOV @R1, #0x80
    RET


SEG_BOARD_FUNCS SEGMENT CODE

RSEG SEG_BOARD_FUNCS

FUN_SELECT_NEXT_PIECE:
    MOV A, CURRENT_PIECE_INDEX
    INC A
    CJNE A, #7, STORE_NEXT_PIECE
    MOV A, #0
STORE_NEXT_PIECE:
    MOV CURRENT_PIECE_INDEX, A
    RET


FUN_CLEAR:
    MOV R0, #GAMESCREEN    
    MOV @R0, #0xFF
    INC R0
    MOV @R0, #0xAA
    INC R0
DRAW_CLEAR:
    MOV @R0, #0000$0000b
    INC R0
    CJNE R0, #GAMESCREEN_END + 1, DRAW_CLEAR
    RET

FUN_DRAW_BACKGROUND:
    MOV R6, #31
    MOV R0, #GAMESCREEN
DRAW_SIDES:
    MOV @R0, #1000$0000b
    INC R0
    MOV @R0, #0000$0001b
    INC R0
    DJNZ R6, DRAW_SIDES
    MOV @R0, #0xFF
    INC R0
    MOV @R0, #0xFF
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
    MOV TH1, #0xD2
    MOV TL1, #0x0C
    SETB TR1

    ; decrement gametick subcounter
    DEC GAMETICK_SUB_COUNTER
    ; check if sub counter has been reached
    JNZ SUB_GAMETICK_RETURN

    ; load max ticks for current level
    MOV DPTR, #DAT_LEVEL_TICKS
    MOV A, CURRENT_LEVEL
    MOVC A, @A+DPTR
    MOV GAMETICK_SUB_COUNTER, A
    
    ;CALL FUN_SIMULATE_PLAYER_INPUT
    CALL FUN_GAMETICK

SUB_GAMETICK_RETURN:
    RETI

EXTRN BIT (BIT_MOVE_LEFT, BIT_MOVE_RIGHT, BIT_MOVE_ROTATE_LEFT, BIT_MOVE_ROTATE_RIGHT)

FUN_GAMETICK:
    ; remove the piece from the board
    CALL FUN_REMOVE_PIECE
    ; process player input
HANDLE_MOVE_LEFT:
    JNB BIT_MOVE_LEFT, HANDLE_MOVE_RIGHT
    CLR BIT_MOVE_LEFT
    CALL FUN_SHIFT_PIECE_LEFT
    CALL FUN_CHECK_COLLISION
    ; check if no collision
    JNC HANDLE_MOVE_RIGHT
    ; otherwise undo
    CALL FUN_SHIFT_PIECE_RIGHT
HANDLE_MOVE_RIGHT:
    JNB BIT_MOVE_RIGHT, HANDLE_MOVE_ROTATE_LEFT
    CLR BIT_MOVE_RIGHT
    CALL FUN_SHIFT_PIECE_RIGHT
    CALL FUN_CHECK_COLLISION
    ; check if no collision
    JNC HANDLE_MOVE_ROTATE_LEFT
    ; otherwise undo
    CALL FUN_SHIFT_PIECE_LEFT
HANDLE_MOVE_ROTATE_LEFT:
    JNB BIT_MOVE_ROTATE_LEFT, HANDLE_MOVE_ROTATE_RIGHT
    CLR BIT_MOVE_ROTATE_LEFT
    CALL FUN_ROTATE_PIECE_LEFT
    CALL FUN_CHECK_COLLISION
    ; check if no collision
    JNC HANDLE_MOVE_ROTATE_RIGHT
    ; otherwise undo
    CALL FUN_ROTATE_PIECE_RIGHT
HANDLE_MOVE_ROTATE_RIGHT:
    JNB BIT_MOVE_ROTATE_RIGHT, HANDLE_MOVE_DOWN
    CLR BIT_MOVE_ROTATE_RIGHT
    CALL FUN_ROTATE_PIECE_RIGHT
    CALL FUN_CHECK_COLLISION
    ; check if no collision
    JNC HANDLE_MOVE_DOWN
    ; otherwise undo
    CALL FUN_ROTATE_PIECE_LEFT
HANDLE_MOVE_DOWN:
    INC CURRENT_PIECE_V_POS
    CALL FUN_CHECK_COLLISION
    JNC CAN_MOVE_DOWN
    DEC CURRENT_PIECE_V_POS
    MOV A, CURRENT_PIECE_V_POS
    CJNE A, #0, STILL_ROOM
    ; when we arrive here, the game has been lost
    ; stop new pieces from spawning
    ; TODO: switch gamestate (also todo) to end
    CALL FUN_DRAW_BACKGROUND
    RET
STILL_ROOM:
    CALL FUN_ADD_PIECE
    CALL FUN_FIND_FULL_ROW
    JNC NO_ROW_FILLED
    ; R1 now contains the filled row adress (left/first byte)
    CALL FUN_MOVE_ROWS_DOWN
NO_ROW_FILLED:
    MOV CURRENT_PIECE_V_POS, #0
    CALL FUN_SELECT_NEXT_PIECE
    CALL FUN_DECOMPRESS_PIECE
CAN_MOVE_DOWN:
    CALL FUN_ADD_PIECE
    RET


SEG_SIMULATION SEGMENT CODE

RSEG SEG_SIMULATION

FUN_SIMULATE_PLAYER_INPUT:
    MOV A, TL0
    JNB ACC.3, SET_RIGHT
    SETB BIT_MOVE_LEFT
SET_RIGHT:
    JNB ACC.2, SET_ROT_LEFT
    SETB BIT_MOVE_RIGHT
SET_ROT_LEFT:
    JNB ACC.1, SET_ROT_RIGHT
    SETB BIT_MOVE_ROTATE_LEFT
SET_ROT_RIGHT:
    JNB ACC.0, SET_END
    SETB BIT_MOVE_ROTATE_RIGHT
SET_END:
    RET


END
