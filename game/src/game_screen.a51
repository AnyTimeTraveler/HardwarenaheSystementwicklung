NAME game_screen

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

FUN_ADD_PIECE_COLOR:
    ; move to current piece location
    MOV A, #COLOURMAP
    ADD A, CURRENT_PIECE_V_POS
    ADD A, CURRENT_PIECE_V_POS
    MOV R1, A
    ; load current piece address
    MOV R0, #CURRENT_PIECE_DECOMPRESSED

    JNB BIT_CURRENT_COLOR, APC_REMOVE_BITS
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
APC_REMOVE_BITS:
    REPT 8
    ; load current piece byte
    MOV A, @R0
    ; invert it
    XRL A, #0xFF
    ; or it with the gamescreen to insert it
    ANL A, @R1
    ; write back to gamescreen
    MOV @R1, A
    ; increment both adresses
    INC R1
    INC R0
    ENDM
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

EXTRN IDATA (GAMESCREEN_END)
EXTRN NUMBER (GAMESCREEN_LEN)

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
    MOV A, R1
    MOV A, R0
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

; PARAM R1 Row to fill first
FUN_MOVE_ROWS_DOWN_COLOR:
    ; move R0 to the row above
    MOV A, R1
    ADD A, #GAMESCREEN_LEN
    MOV R0, A
    MOV R1, A
    INC R1
    DEC R0
MOVE_DOWN_COLOR:
    MOV A, @R0
    MOV @R1, A
    DEC R0
    DEC R1
    CJNE R1, #COLOURMAP + 1, MOVE_DOWN_COLOR
    MOV @R1, #0x00
    DEC R1
    MOV @R1, #0x00
    RET

END
