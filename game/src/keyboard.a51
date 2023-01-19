NAME keyboard

SEG_KEYBOARD SEGMENT CODE

EXTRN BIT (BIT_KEYBOARD_BREAK)
EXTRN CODE (PFUN_MOVE_LEFT, PFUN_MOVE_RIGHT, PFUN_ROTATE_RIGHT, PFUN_GAMETICK, FUN_CLEAR, PFUN_DRAW_BACKGROUND)
EXTRN IDATA (GAMESCREEN, GAMESCREEN_END)
EXTRN DATA (DEBUG)
PUBLIC PJMPI_KEYBOARD_ISR

RSEG SEG_KEYBOARD
PJMPI_KEYBOARD_ISR:
    PUSH PSW
    CLR RS0
    CLR RS1
    USING 0
    MOV A, SBUF
    CLR RI
    JMP ACTUAL
    MOV R0, DEBUG
    MOV @R0, A
    INC R0
    MOV A, #0xAA
    MOV @R0, A
    INC R0
    INC R0
    INC R0
    MOV DEBUG, R0
    CJNE R0, #GAMESCREEN_END - 2, NEQUAL
HANG:
;    JMP $
;    JB P1.4, $
    CALL FUN_CLEAR
    MOV DEBUG, #GAMESCREEN + 4
    POP PSW
    RETI
NEQUAL:
    JNC HANG
    POP PSW
    RETI
ACTUAL:
    ; check if byte is E0
    CJNE A, #0xE0, NOT_E0
    ; ignore the E0 byte
    JMP RETURN
NOT_E0:
    ; check for a break code
    CJNE A, #0xF0, NOT_BREAK
    ; set the break bit
    SETB BIT_KEYBOARD_BREAK
    JMP RETURN
NOT_BREAK:
    ; it's not a break, so check the break flag, if that is true then ignore the keypress
    JB BIT_KEYBOARD_BREAK, UNSET_BREAK
    ; it's a make byte, so get the key pressed

    ; check LEFT-ARROW
    CJNE A, #0x6B, NOT_LEFT
    CALL PFUN_MOVE_RIGHT
    JMP RETURN
NOT_LEFT:
    ; check RIGHT-ARROW
    CJNE A, #0x74, NOT_RIGHT
    CALL PFUN_MOVE_LEFT
    JMP RETURN
NOT_RIGHT:
    ; check UP-ARROW
    CJNE A, #0x75, NOT_UP
    CALL PFUN_ROTATE_RIGHT
    JMP RETURN
NOT_UP:
    ; check DOWN-ARROW
    CJNE A, #0x72, NOT_DOWN
    CALL PFUN_GAMETICK
    JMP RETURN    
NOT_DOWN:
    ; check DOWN-ARROW
    CJNE A, #0x2D, NOT_R
    CALL PFUN_DRAW_BACKGROUND
    JMP RETURN

UNSET_BREAK:
    CLR BIT_KEYBOARD_BREAK
NOT_R:
RETURN:
    POP PSW
    RETI

PUBLIC PJMPI_VIRTUAL_KEYBOARD
EXTRN BIT (VIRTUAL_KEYBOARD_INPUT)

CSEG AT 0x002C
PJMPI_VIRTUAL_KEYBOARD:
    PUSH ACC
    MOV A, 0xFE
    JNB ACC.0, SKIP_LEFT
    CALL PFUN_MOVE_LEFT
SKIP_LEFT:
    MOV A, 0xFE
    JNB ACC.1, SKIP_RIGHT
    CALL PFUN_MOVE_RIGHT
SKIP_RIGHT:
    MOV A, 0xFE
    JNB ACC.2, SKIP_ROTATE
    CALL PFUN_ROTATE_RIGHT
SKIP_ROTATE:
    MOV A, 0xFE
    JNB ACC.3, SKIP_DOWN
    CALL PFUN_GAMETICK
SKIP_DOWN:
    POP ACC
    RETI

END
