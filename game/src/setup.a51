NAME timer

SEG_TIMERS SEGMENT CODE

PUBLIC PFUN_SETUP_TIMERS

RSEG SEG_TIMERS
PFUN_SETUP_TIMERS:
    ; Timer 1 $ Timer 0
    ; MODE BITS
    ; GATE | Counter/Timer | Mode 1 | Mode 0
    ; 
    ; Mode 00: 13 Bit Timer, 5 Bit Prescaler
    ; Mode 01: 16 Bit Timer, 0 Bit Prescaler
    ; Mode 10:  8 Bit Timer, 8 Bit Auto-Reload
    ; Mode 11: 2x 8 Bit Timer (separat)
    ; 
    MOV TMOD, #0001$0001b
    
    ; Interrupts allgemein aktivieren
    SETB EA
    
    ; Timer 0 Interrupt aktivieren
    SETB ET0
    ; Timer 1 Interrupt aktivieren
    SETB ET1
    
    ; Timer 0 Run (Gamescreen) aktivieren
    SETB TR0
    ; Timer 1 Run (Gametick) deaktivieren, bis Baudrate-Detection fertig ist
    CLR TR1

    RET

END
