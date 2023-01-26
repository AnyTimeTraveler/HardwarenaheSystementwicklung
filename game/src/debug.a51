NAME debug

PUBLIC PFUN_SERIAL_WRITE

PFUN_SERIAL_WRITE:
    REPT 8
    CLR C
    RRC A
    MOV P1.4, C
    SETB P1.3
    ; NOP
    ; NOP
    ; NOP
    CLR P1.3
    CLR P1.4
    ; NOP
    ; NOP
    ; NOP
    ENDM
    RET

END
