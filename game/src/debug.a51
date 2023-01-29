NAME debug

SEG_DEBUG SEGMENT CODE

EXTRN BIT (OUT_DATA, OUT_CLK)
PUBLIC PFUN_SERIAL_WRITE

RSEG SEG_DEBUG
; Writes one byte (ACC) msb-first to serial
; ACC is preserved, Carry is cleared
PFUN_SERIAL_WRITE:
    REPT 8
        RLC A
        MOV OUT_DATA, C
        SETB OUT_CLK
        CLR OUT_CLK
        ;CLR OUT_DATA
    ENDM
    RLC A
    RET

END
