NAME init

SEG_INIT SEGMENT CODE

EXTRN DATA (GAMESTATE, SCREEN_REFRESH_CURRENT_ROW, T2CON, STACK)
EXTRN CODE (GS_FIRST_RUN, PFUN_FILL_SCREEN, PFUN_CLEAR_SCREEN, PFUN_DETECT_BAUDRATE, PJMP_GAMELOOP)
EXTRN IDATA (GAMESCREEN)
EXTRN NUMBER (GAMESCREEN_LEN)
PUBLIC PJMP_INIT

RSEG SEG_INIT
PJMP_INIT:
    ; user registerbank 0 for the whole program
    CLR RS0
    CLR RS1

    ; move stack to the indirect addressed area, so the other register banks are free
    ; normally, the stack starts at 0x07, which is the start of the second register bank
    MOV SP, #STACK

    MOV GAMESTATE, #GS_FIRST_RUN
    MOV SCREEN_REFRESH_CURRENT_ROW, #0

    CALL FUN_SETUP_TIMERS

    ; Interrupts allgemein aktivieren
    SETB EA

    CALL FUN_SET_INTERRUPT_PRIORITIES

    CALL PFUN_FILL_SCREEN
    ; CALL PFUN_DETECT_BAUDRATE
    CALL FUN_SETUP_SERIAL

    SETB ET1
    SETB TR1

    CALL PFUN_CLEAR_SCREEN

    JMP PJMP_GAMELOOP


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
    

    ; TIMER COUNTER 2 CONTROL MODE BITS
    ; TF2 | EXF2 | RCLK | TCLK | EXEN2 | TR2 | CT2 | CPRL2
    ; 
    ; TF2   : timer 2 interrupt flag
    ; EXF2  : timer 2 external flag
    ; RCLK  : receive clock flag (baudrate generator)
    ; TCLK  : transmit clock flag (baudrate generator)
    ; 
    ; EXEN2 : timer 2 external enable flag
    ; TR2   : timer 2 run
    ; CT2   : timer 2 counter / timer mode
    ; CPRL2 : capture/reload flag (ignored in baudarate gen. mode)
    ; 
    MOV T2CON, #0000$0000b


    ; Timer 0 Interrupt aktivieren
    SETB ET0
    ; Timer 1 Interrupt deaktivieren
    CLR ET1

    ; Timer 0 Run (Gamescreen) aktivieren
    SETB TR0
    ; Timer 1 Run (Gametick) aktivieren
    CLR TR1

    RET

FUN_SETUP_SERIAL:
    ; TIMER COUNTER 2 CONTROL MODE BITS
    ; TF2 | EXF2 | RCLK | TCLK | EXEN2 | TR2 | CT2 | CPRL2
    ; 
    ; TF2   : timer 2 interrupt flag
    ; EXF2  : timer 2 external flag
    ; RCLK  : receive clock flag (baudrate generator)
    ; TCLK  : transmit clock flag (baudrate generator)
    ; 
    ; EXEN2 : timer 2 external enable flag
    ; TR2   : timer 2 run
    ; CT2   : timer 2 counter / timer mode
    ; CPRL2 : capture/reload flag (ignored in baudarate gen. mode)
    ; 
    MOV T2CON, #0011$0100b

    ; SERIAL CONTROL MODE BITS
    ; SM[0,1] | SM2 | REN | TB8 | RB8 | TI | RI
    ; 
    ; SM 00 : Mode 0 : f/12 : shift
    ; SM 01 : Mode 1 : var  : 8-bit
    ; SM 10 : Mode 2 : f/32 : 9-bit
    ; SM 11 : Mode 3 : var  : 9-bit
    ; 
    ; SM2   : Multiprocessor Mode
    ; REN   : Receive enable
    ; TB8   : 9th transmit bit
    ; RB8   : 9th receive bit
    ; TI    : transmit interrupt flag
    ; RI    : receive interrupt flag
    ;
    MOV SCON, #1101$0000b

    ; enable serial interrupts
    SETB ES
    RET

FUN_SET_INTERRUPT_PRIORITIES:
    ; give screen (timer 0) high priority
    CLR PT0
    ; give keyboard (serial) low priority
    CLR PS
    ; give gameticks (timer 1) low priority
    CLR PT1
    RET

END
