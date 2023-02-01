NAME game_screen

SEG_GAME_SCREEN SEGMENT CODE

EXTRN BIT (BIT_CURRENT_COLOR)
EXTRN DATA (CURRENT_PIECE_V_POS, CURRENT_PIECE_DECOMPRESSED)
EXTRN IDATA (GAMESCREEN)
EXTRN CODE (DAT_LOGO)
EXTRN NUMBER (GAMESCREEN_LEN, GAMESCREEN_ROW_LEN, GAMESCREEN_ROWS)
PUBLIC PFUN_ADD_PIECE, PFUN_REMOVE_PIECE, PFUN_CHECK_COLLISION, PFUN_DRAW_BACKGROUND
PUBLIC PFUN_FIND_FULL_ROW, PFUN_MOVE_ROWS_DOWN, PFUN_CLEAR_SCREEN, PFUN_FILL_SCREEN, PFUN_LOAD_LOGO_LINE

RSEG SEG_GAME_SCREEN
PFUN_ADD_PIECE:
    ; move to current piece location
    MOV A, CURRENT_PIECE_V_POS
    MOV B, #4
    MUL AB
    ADD A, #GAMESCREEN
    MOV R1, A
    ; load current piece address
    MOV R0, #CURRENT_PIECE_DECOMPRESSED
    REPT 16
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

PFUN_REMOVE_PIECE:
    ; move to current piece location
    MOV A, CURRENT_PIECE_V_POS
    MOV B, #4
    MUL AB
    ADD A, #GAMESCREEN
    MOV R1, A
    ; load current piece address
    MOV R0, #CURRENT_PIECE_DECOMPRESSED
    ; for each byte of the current piece
    REPT 16
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
    MOV A, CURRENT_PIECE_V_POS
    MOV B, #4
    MUL AB
    ADD A, #GAMESCREEN
    ; Store row address in R1
    MOV R1, A
    MOV R0, #CURRENT_PIECE_DECOMPRESSED
    REPT 16
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
    MOV A, #GAMESCREEN
    ADD A, #GAMESCREEN_LEN
    CLR C
    ; start at the second to lowest line
    SUBB A, #GAMESCREEN_ROW_LEN
    ; now R1 is at the 2nd byte of the lowest line
LINE_START:
    CJNE @R1, #0xFF, SKIP_FOUR
    DEC R1
    CJNE @R1, #0xFF, SKIP_THREE
    DEC R1
    CJNE @R1, #0xFF, SKIP_TWO
    DEC R1
    CJNE @R1, #0xFF, SKIP_ONE
    ; full line has been found
    SETB C
    RET
SKIP_FOUR:
    DEC R1
SKIP_THREE:
    DEC R1
SKIP_TWO:
    DEC R1
SKIP_ONE:
    DEC R1
    ; keep going until we're at the top line
    CJNE R1, #GAMESCREEN, LINE_START
    CLR C
    RET

; PARAM R1 Row to fill first
PFUN_MOVE_ROWS_DOWN:
    ; move R0 to the row above
    MOV A, R1
    MOV R0, A
    INC R1
    INC R1
    INC R1
    DEC R0
MOVE_DOWN:
    MOV A, @R0
    MOV @R1, A
    DEC R0
    DEC R1
    CJNE R1, #GAMESCREEN, MOVE_DOWN
    ; at the top row, draw the sides
    MOV @R1, #0x80
    INC R1
    MOV @R1, #0x00
    INC R1
    MOV @R1, #0x00
    INC R1
    MOV @R1, #0x01
    RET

PFUN_CLEAR_SCREEN:
    MOV R0, #GAMESCREEN
    MOV A, #0x00
    JMP FUN_FILL_SCREEN

PFUN_FILL_SCREEN:
    MOV R0, #GAMESCREEN
    MOV A, #0xFF
    JMP FUN_FILL_SCREEN

; PARAM A byte to fill screen with
FUN_FILL_SCREEN:
    MOV R1, #GAMESCREEN_LEN
DRAW_FILL:
    MOV @R0, A
    INC R0
    DJNZ R1, DRAW_FILL
    RET

PFUN_DRAW_BACKGROUND:
    MOV R1, #GAMESCREEN_ROWS - 1
    MOV R0, #GAMESCREEN
DRAW_SIDES:
    MOV @R0, #0x80
    INC R0
    MOV @R0, #0x00
    INC R0
    MOV @R0, #0x00
    INC R0
    MOV @R0, #0x01
    INC R0
    DJNZ R1, DRAW_SIDES
    MOV @R0, #0xFF
    INC R0
    MOV @R0, #0xFF
    INC R0
    MOV @R0, #0xFF
    INC R0
    MOV @R0, #0xFF
    RET

; PARAM R1 Index to be loaded
PFUN_LOAD_LOGO_LINE:
    ; load gamescreen address into R0
    MOV A, #GAMESCREEN
    ADD A, R1
    MOV R0, A
    MOV DPTR, #DAT_LOGO

    ; load logo byte
    MOV A, R1
    MOVC A, @A + DPTR
    ; write byte to gamescreen
    MOV @R0, A
    INC R0
    INC R1

    ; load logo byte
    MOV A, R1
    MOVC A, @A + DPTR
    ; write byte to gamescreen
    MOV @R0, A
    INC R0
    INC R1

    ; load logo byte
    MOV A, R1
    MOVC A, @A + DPTR
    ; write byte to gamescreen
    MOV @R0, A
    INC R0
    INC R1

    ; load logo byte
    MOV A, R1
    MOVC A, @A + DPTR
    ; write byte to gamescreen
    MOV @R0, A
    INC R0
    INC R1


    RET

END
