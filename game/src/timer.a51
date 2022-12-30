NAME timer

SEG_SETUP_TIMER_0 SEGMENT CODE

PUBLIC PFUN_SETUP_TIMER_0

RSEG SEG_SETUP_TIMER_0
PFUN_SETUP_TIMER_0:
    ; Timer 1 $ Timer 0
    ; MODE BITS
    ; GATE | Counter/Timer | Mode 1 | Mode 0
    ; 
    ; Mode 00: 13 Bit Timer, 5 Bit Prescaler
    ; Mode 01: 16 Bit Timer, 0 Bit Prescaler
    ; Mode 10:  8 Bit Timer, 8 Bit Auto-Reload
    ; Mode 11: 2x 8 Bit Timer (separat)
    ; 
    MOV TMOD, #0010$0001b  
    
    ; Interrupts allgemein aktivieren
    SETB EA
    
    ; Timer 0 Interrupt aktivieren
    SETB ET0
    
    ; Timer 0 Run aktivieren
    SETB TR0
    
    RET

END
