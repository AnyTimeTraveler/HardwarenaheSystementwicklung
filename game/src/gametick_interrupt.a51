NAME gametick_interrupt

SEG_GAMETICK SEGMENT CODE

PUBLIC PJMPI_SUB_GAMETICK
EXTRN CODE (DAT_LEVEL_TICKS)
EXTRN DATA (GAMETICK_SUB_COUNTER, CURRENT_LEVEL)
EXTRN BIT (BIT_RUN_GAMETICK)

RSEG SEG_GAMETICK
PJMPI_SUB_GAMETICK:
    PUSH PSW
    SETB RS0
    USING 1
    ; Reload with DF76
    ; for 200 Interrupts per Second
    ; Actually, reload with D20C
    ; for one tick every 7 ms (one gametick on lv 15) and scale from there
    MOV TH1, #0xD2
    MOV TL1, #0x0C

    ; decrement gametick subcounter
    DEC GAMETICK_SUB_COUNTER
    MOV A, GAMETICK_SUB_COUNTER
    ; check if sub counter has been reached
    JNZ SUB_GAMETICK_RETURN

    ; load max ticks for current level
    MOV DPTR, #DAT_LEVEL_TICKS
    MOV A, CURRENT_LEVEL
    MOVC A, @A + DPTR
    MOV GAMETICK_SUB_COUNTER, A

    SETB BIT_RUN_GAMETICK

SUB_GAMETICK_RETURN:
    POP PSW
    RETI

END
