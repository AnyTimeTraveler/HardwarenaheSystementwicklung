NAME keyboard

SEG_KEYBOARD SEGMENT CODE

EXTRN BIT (BIT_KEYBOARD_BREAK, BIT_RUN_GAMETICK)
EXTRN CODE (PFUN_MOVE_LEFT, PFUN_MOVE_RIGHT, PFUN_ROTATE_RIGHT, PFUN_RESET_GAME)
EXTRN NUMBER (KDB_EXTENDED, KDB_BREAK, KDB_KEY_LEFT_ARROW, KDB_KEY_RIGHT_ARROW, KDB_KEY_UP_ARROW, KDB_KEY_DOWN_ARROW, KDB_KEY_R)
PUBLIC PJMPI_KEYBOARD_ISR

RSEG SEG_KEYBOARD
PJMPI_KEYBOARD_ISR:
    PUSH PSW
    CLR RS0
    SETB RS1
    USING 2
    MOV A, SBUF
    CLR RI
    ; ignore the E0 byte
    CJNE A, #KDB_EXTENDED, NOT_E0
    JMP RETURN

NOT_E0:
    ; check for a break byte
    CJNE A, #KDB_BREAK, NOT_BREAK
    ; set the break bit to ignore break keystorkes
    SETB BIT_KEYBOARD_BREAK
    JMP RETURN

NOT_BREAK:
    ; it's not a break, so check the break flag, if that is true then ignore the keypress
    JB BIT_KEYBOARD_BREAK, UNSET_BREAK
    ; it's a make byte, so get the key pressed

    CJNE A, #KDB_KEY_LEFT_ARROW, NOT_LEFT
    CALL PFUN_MOVE_RIGHT
    JMP RETURN
NOT_LEFT:
    CJNE A, #KDB_KEY_RIGHT_ARROW, NOT_RIGHT
    CALL PFUN_MOVE_LEFT
    JMP RETURN
NOT_RIGHT:
    CJNE A, #KDB_KEY_UP_ARROW, NOT_UP
    CALL PFUN_ROTATE_RIGHT
    JMP RETURN
NOT_UP:
    CJNE A, #KDB_KEY_DOWN_ARROW, NOT_DOWN
    ; CALL PFUN_GAMETICK
    SETB BIT_RUN_GAMETICK
    JMP RETURN
NOT_DOWN:
    CJNE A, #KDB_KEY_R, NOT_R
    CALL PFUN_RESET_GAME
    JMP RETURN

UNSET_BREAK:
    CLR BIT_KEYBOARD_BREAK
NOT_R:
RETURN:
    POP PSW
    RETI

END
