NAME game_screen

SEG_GAME_SCREEN SEGMENT CODE

EXTRN BIT (BIT_CURRENT_COLOR)
EXTRN DATA (CURRENT_PIECE_V_POS, CURRENT_PIECE_DECOMPRESSED, SCREEN_START, SCREEN_LEN, SCREEN_COLOUR)
PUBLIC PFUN_ADD_PIECE, PFUN_ADD_PIECE_COLOR, PFUN_REMOVE_PIECE, PFUN_CHECK_COLLISION, PFUN_DRAW_BACKGROUND
PUBLIC PFUN_FIND_FULL_ROW, PFUN_MOVE_ROWS_DOWN, PFUN_MOVE_ROWS_DOWN_COLOR, PFUN_FILL_SCREEN

RSEG SEG_GAME_SCREEN
PFUN_ADD_PIECE:
    ; move to current piece location
    MOV A, SCREEN_START
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

PFUN_ADD_PIECE_COLOR:
    RET
    ; move to current piece location
    MOV A, SCREEN_COLOUR
    ADD A, CURRENT_PIECE_V_POS
    ADD A, CURRENT_PIECE_V_POS
    MOV R1, A
    ; load current piece address
    MOV R0, #CURRENT_PIECE_DECOMPRESSED

    JNB BIT_CURRENT_COLOR, APC_REMOVE_BITS
    REPT 8
    ; load current piece byte
    MOV A, @R0
    ; or it with the colour screen to insert it
    ORL A, @R1
    ; write back to colour screen
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
    ; and it with the colour screen to remove it
    ANL A, @R1
    ; write back to colour screen
    MOV @R1, A
    ; increment both adresses
    INC R1
    INC R0
    ENDM
    RET

PFUN_REMOVE_PIECE:
    ; move to current piece location
    MOV A, SCREEN_START
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
RP_RET:
    RET


; RETURN C if collision
PFUN_CHECK_COLLISION:
    ; Calculate next screen row
    MOV A, SCREEN_START
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
PFUN_FIND_FULL_ROW:
    MOV A, SCREEN_START
    ADD A, SCREEN_LEN
    CLR C
    ; start at the second to lowest line
    SUBB A, #2
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
    MOV A, R1
    CJNE A, SCREEN_START, LINE_START
    CLR C
    RET


; ; PARAM R1 Row to clear (preserved)
; PFUN_CLEAR_ROW:
;     MOV @R1, #0x80
;     INC R1
;     MOV @R1, #0x01
;     DEC R1
;     RET

; ; PARAM R1 Row to fill (preserved)
; PFUN_FILL_ROW:
;     MOV @R1, #0xFF
;     INC R1
;     MOV @R1, #0xFF
;     DEC R1
;     RET

; PARAM R1 Row to fill first
PFUN_MOVE_ROWS_DOWN:
    ; move R0 to the row above
    MOV A, R1
    MOV R0, A
    INC R1
    DEC R0
MOVE_DOWN:
    MOV A, @R0
    MOV @R1, A
    DEC R0
    DEC R1
    MOV A, R1
    CJNE A, SCREEN_START, MOVE_DOWN
    ; at the top row, draw the sides
    MOV @R1, #0x80
    INC R1
    MOV @R1, #0x01
    RET

; PARAM R1 Row to fill first
PFUN_MOVE_ROWS_DOWN_COLOR:
    RET
    ; move R0 to the row above
    MOV A, R1
    ADD A, SCREEN_LEN
    MOV R0, A
    MOV R1, A
    INC R1
    DEC R0
MOVE_DOWN_COLOR:
    MOV A, @R0
    MOV @R1, A
    DEC R0
    DEC R1
    MOV A, R1
    CJNE A, SCREEN_COLOUR, MOVE_DOWN_COLOR
    MOV @R1, #0x00
    INC R1
    MOV @R1, #0x00
    RET

; PARAM R0 screen to fill
; PARAM A byte to fill screen with
PFUN_FILL_SCREEN:
    MOV R1, SCREEN_LEN
DRAW_FILL:
    MOV @R0, A
    INC R0
    DJNZ R1, DRAW_FILL
    RET

PFUN_DRAW_BACKGROUND:
    MOV A, SCREEN_START
    ADD A, SCREEN_LEN
    CLR C
    SUBB A, #2
    MOV R0, SCREEN_START
DRAW_SIDES:
    MOV @R0, #0x80
    INC R0
    MOV @R0, #0x01
    INC R0
    USING 0
    CJNE A, AR0, DRAW_SIDES
    MOV @R0, #0xFF
    INC R0
    MOV @R0, #0xFF
    RET


END
