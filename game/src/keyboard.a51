NAME keyboard

SEG_KEYBOARD SEGMENT CODE

EXTRN BIT (BIT_KEYBOARD_BREAK, BIT_MOVE_LEFT, BIT_MOVE_RIGHT, BIT_MOVE_ROTATE_RIGHT, BIT_MOVE_DOWN)
PUBLIC PJMPI_KEYBOARD_ISR

RSEG SEG_KEYBOARD
PJMPI_KEYBOARD_ISR:
    MOV A, SBUF
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
    SETB BIT_MOVE_LEFT
    JMP RETURN
NOT_LEFT:
    ; check RIGHT-ARROW
    CJNE A, #0x74, NOT_RIGHT
    SETB BIT_MOVE_RIGHT
    JMP RETURN
NOT_RIGHT:
    ; check UP-ARROW
    CJNE A, #0x75, NOT_UP
    SETB BIT_MOVE_ROTATE_RIGHT
    JMP RETURN
NOT_UP:
    ; check DOWN-ARROW
    CJNE A, #0x72, NOT_DOWN
    SETB BIT_MOVE_DOWN
    JMP RETURN

UNSET_BREAK:
    CLR BIT_KEYBOARD_BREAK
NOT_DOWN:
RETURN:
    RETI

END
