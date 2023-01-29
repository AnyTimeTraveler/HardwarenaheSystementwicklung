NAME game_screen

SEG_GAME_SCREEN SEGMENT CODE

; EXTRN BIT ()

RSEG SEG_GAME_SCREEN

FUN_ADD_PIECE:
    ; move to current piece location
    MOV A, #GAMESCREEN_0
    ADD A, CURRENT_PIECE_V_POS
    ADD A, CURRENT_PIECE_V_POS
    MOV R1, A
    ; load current piece address
    MOV R0, #CURRENT_PIECE_DECOMPRESSED
    REPT 8
    ; load current piece byte
    MOV A, @R0
    ; or it with the GAMESCREEN_0 to insert it
    ORL A, @R1
    ; write back to GAMESCREEN_0
    MOV @R1, A
    ; increment both adresses
    INC R1
    INC R0
    ENDM
    RET

FUN_ADD_PIECE_COLOR:
    ; move to current piece location
    MOV A, #GAMESCREEN_1
    ADD A, CURRENT_PIECE_V_POS
    ADD A, CURRENT_PIECE_V_POS
    MOV R1, A
    ; load current piece address
    MOV R0, #CURRENT_PIECE_DECOMPRESSED

    JNB BIT_CURRENT_COLOR, APC_REMOVE_BITS
    REPT 8
    ; load current piece byte
    MOV A, @R0
    ; or it with the GAMESCREEN_0 to insert it
    ORL A, @R1
    ; write back to GAMESCREEN_0
    MOV @R1, A
    ; increment both adresses
    INC R1
    INC R0
    ENDM
    RET
APC_REMOVE_BITS:
    REPT 8
    ; load current piece byte
    MOV A, @R0
    ; invert it
    XRL A, #0xFF
    ; or it with the GAMESCREEN_0 to insert it
    ANL A, @R1
    ; write back to GAMESCREEN_0
    MOV @R1, A
    ; increment both adresses
    INC R1
    INC R0
    ENDM
    RET

FUN_REMOVE_PIECE:
    ; move to current piece location
    MOV A, #GAMESCREEN_0
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
    ; write back to GAMESCREEN_0
    MOV @R1, A
    ; increment both adresses
    INC R1
    INC R0
    ENDM
RP_RET:
    RET


; RETURN C if collision
FUN_CHECK_COLLISION:
    ; Calculate next GAMESCREEN_0 row
    MOV A, #GAMESCREEN_0
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


; RETURN C if there is a full row
; RETURN R1 address of full row, if any
FUN_FIND_FULL_ROW:
    ; start at the second to lowest line
    MOV R1, #GAMESCREEN_0_END - 2
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
    CJNE R1, #GAMESCREEN_0 + 1, LINE_START
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
    MOV A, R1
    MOV A, R0
    INC R1
    DEC R0
MOVE_DOWN:
    MOV A, @R0
    MOV @R1, A
    DEC R0
    DEC R1
    CJNE R1, #GAMESCREEN_0 + 1, MOVE_DOWN
    ; at the top row, draw the sides
    MOV @R1, #0x01
    DEC R1
    MOV @R1, #0x80
    RET

; PARAM R1 Row to fill first
FUN_MOVE_ROWS_DOWN_COLOR:
    ; move R0 to the row above
    MOV A, R1
    ADD A, #GAMESCREEN_0_LEN
    MOV R0, A
    MOV R1, A
    INC R1
    DEC R0
MOVE_DOWN_COLOR:
    MOV A, @R0
    MOV @R1, A
    DEC R0
    DEC R1
    CJNE R1, #GAMESCREEN_1 + 1, MOVE_DOWN_COLOR
    MOV @R1, #0x00
    DEC R1
    MOV @R1, #0x00
    RET


FUN_CLEAR:
    MOV R0, #GAMESCREEN_0
    MOV @R0, #0xFF
    INC R0
    MOV @R0, #0xAA
    INC R0
DRAW_CLEAR:
    MOV @R0, #0x00
    INC R0
    CJNE R0, #GAMESCREEN_0_END + 1, DRAW_CLEAR
    RET

FUN_FILL:
    MOV R0, #GAMESCREEN_0
DRAW_FILL:
    MOV @R0, #0xFF
    INC R0
    CJNE R0, #GAMESCREEN_0_END + 1, DRAW_FILL
    MOV R0, #GAMESCREEN_1
DRAW_FILL_COLOR:
    MOV @R0, #0xAA
    INC R0
    CJNE R0, #GAMESCREEN_1 + GAMESCREEN_LEN, DRAW_FILL_COLOR
    RET

FUN_DRAW_BACKGROUND:
    MOV R6, #31
    MOV R0, #GAMESCREEN_0
DRAW_SIDES:
    MOV @R0, #0x80
    INC R0
    MOV @R0, #0x01
    INC R0
    DJNZ R6, DRAW_SIDES
    MOV @R0, #0xFF
    INC R0
    MOV @R0, #0xFF
    RET


END
