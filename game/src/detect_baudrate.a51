NAME detect_baudrate

; 


SEG_DETECT_BAUDRATE SEGMENT CODE

EXTRN DATA (CLOCK_SAMPLES_BEGIN, CLOCK_SAMPLES_END, RCAP2L, RCAP2H, T2CON)
EXTRN BIT (BIT_BAUDRATE_DETECTING, BIT_BAUD_ERROR_FLAG)
PUBLIC PJMPI_DETECT_BAUDRATE_ISR, PFUN_DETECT_BAUDRATE

RSEG SEG_DETECT_BAUDRATE
PJMPI_DETECT_BAUDRATE_ISR:
    ; Wenn der Timer noch nicht laeuft
    JB TR1, TIMER_ALREADY_RUNNING
    ; Timer 1 Run aktivieren
    SETB TR1
    RETI
TIMER_ALREADY_RUNNING:
    CLR TR1
    ; Timer-Wert an Adresse in R2 speichern
    MOV @R1, TL1
    ; Timer-Wert zuruecksetzen
    MOV TL1, #0
    SETB TR1
    INC R1
    ; Wenn alle 8 Register voll sind
    CJNE R1, #CLOCK_SAMPLES_END + 1, RETURN
    ; Interrupt deaktivieren
    CLR ET1
RETURN:
    RETI

PFUN_DETECT_BAUDRATE:
    SETB BIT_BAUDRATE_DETECTING
    ; Interrupt INT0 scharf schalten
    SETB EX0
    ; Der Interrupt startet dann Timer 1

    ; Adresse wo die Werte abgespeichert werden sollen
    MOV R1, #CLOCK_SAMPLES_BEGIN

    ; Timer 1 Interrupt aktivieren
    SETB ET1
    ; Warte, bis Externer Interrupt 1 deaktiviert wurde
    JB ET1, $
    CLR EX0
    JNB BIT_BAUD_ERROR_FLAG, SAMPLE_GATHERING_OK
    ; Retry
    JMP SEG_DETECT_BAUDRATE

SAMPLE_GATHERING_OK:
    MOV R1, #CLOCK_SAMPLES_BEGIN
    MOV R2, #0
    MOV A, @R1
    INC R1
ADD_TIMES:
    CALL FUN_ADD16
    INC R1
    CJNE R1, #CLOCK_SAMPLES_END + 1, ADD_TIMES

    ; Timer reload: 2^16 - R2:A
    ; backup lower sum in R3
    MOV R3, A
    MOV A, #255
    CLR C
    SUBB A, R2
    MOV R2, A
    MOV A, #255
    SUBB A, R3
    ; auto-reload now in R2:A
    MOV RCAP2L, A
    MOV RCAP2H, R2

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

    CLR BIT_BAUDRATE_DETECTING
    RET

; PARAM R1: Address of Value to add to A
; PARAM R2: Higher bits of Addition
FUN_ADD16:
    ADD A, @R1
    JNC NO_OVERFLOW
    INC R2
NO_OVERFLOW:
    RET

END
