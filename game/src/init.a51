NAME init

SEG_INIT SEGMENT CODE

PUBLIC PJMP_INIT

RSEG SEG_INIT
PJMP_INIT:
    ; enable registerbank 0
    CLR RS0
    CLR RS1

    ; turn on the LED
    CLR LED

    ; move stack to the indirect addressed area, so the other register banks are free
    ; normally, the stack starts at 0x07, which is the start of the second register bank
    MOV SP, #STACK

    CALL FUN_SETUP_TIMERS

    ; CALL PFUN_CLEAR_SCREEN
    CALL PFUN_DETECT_BAUDRATE
    ; CALL PFUN_FILL_SCREEN

    ; reset game to initial state before starting timer 1 to run gameticks
    CALL PFUN_RESET_GAME

    ; enable serial interrupt for keyboard input
    SETB ES

    ; enable timer 1 for gameticks
    SETB TR1
    SETB ET1
LOOP_MAIN:
    JMP LOOP_MAIN




FUN_SETUP_TIMERS:
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
    CLR ET1
    
    ; Timer 0 Run (Gamescreen) aktivieren
    SETB TR0
    ; Timer 1 Run (Gametick) deaktivieren, bis Baudrate-Detection fertig ist
    CLR TR1

    RET

END
