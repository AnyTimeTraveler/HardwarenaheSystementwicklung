NAME detect_baudrate

; 


SEG_DETECT_BAUDRATE SEGMENT CODE

EXTRN DATA (CLOCK_SAMPLES_BEGIN, CLOCK_SAMPLES_END, RCAP2L, RCAP2H, T2CON)
EXTRN IDATA (GAMESCREEN)
EXTRN BIT (BIT_BAUDRATE_DETECTING, BIT_BAUD_ERROR_FLAG, LED)
PUBLIC PJMPI_DETECT_BAUDRATE_ISR, PFUN_DETECT_BAUDRATE

RSEG SEG_DETECT_BAUDRATE
PJMPI_DETECT_BAUDRATE_ISR:
    ; Wenn der Timer noch nicht laeuft
    JB TR1, TIMER_ALREADY_RUNNING
    ; Timer 1 Run aktivieren
    SETB TR1
    RETI
TIMER_ALREADY_RUNNING:
;    CLR TR1
    ; Timer-Wert an Adresse in R2 speichern
    MOV R3, TL1
    MOV R3, TH1
    ; Timer-Wert zuruecksetzen
    MOV TL1, #0
    MOV TH1, #0
;    SETB TR1
;    CALL FUN_ADD16
    INC R2			    

    MOV A, R2
    MOV @R0, A
    INC R0
    MOV A, R3
    MOV @R0, A
    INC R0
    INC R0
    MOV A, R4
    MOV @R0, A
    INC R0
    INC R0
    INC R0    
    CJNE R2, #5, RETURN
    ; Interrupt deaktivieren
    CLR EX0
RETURN:
    RETI

PFUN_DETECT_BAUDRATE:
    SETB BIT_BAUDRATE_DETECTING   
    ; Der Interrupt startet dann Timer 1

    ; Sample count
    MOV R2, #0
    MOV R0, #GAMESCREEN + 4

    ; ACC
    MOV R3, #0
    MOV R4, #0
    CLR BIT_BAUD_ERROR_FLAG

    ; Timer 1 Interrupt aktivieren
    CLR ET1
    ; Interrupt INT0 scharf schalten
    CLR EX0
    ; Warte, bis Externer Interrupt 1 deaktiviert wurde
    JB P3.2, $
    JNB P3.2, $
    JB P3.2, $
    SETB TR1
    SETB LED
    JNB P3.2, $
    JB P3.2, $
    CLR TR1


    MOV @R0, #0x01
    INC R0
    MOV A, TH1
    MOV @R0, A
    INC R0
    INC R0
    INC R0    
    MOV @R0, #0x02
    INC R0
    MOV A, TL1
    MOV @R0, A
    INC R0
    INC R0
    INC R0
 
    JMP $
    JNB BIT_BAUD_ERROR_FLAG, SAMPLE_GATHERING_OK
    ; Retry
    JMP SEG_DETECT_BAUDRATE

SAMPLE_GATHERING_OK:
    ; Timer reload: 2^16 - (R4:R3 / 16)

    MOV A, R4
    MOV B, R3

    ; / 2
    CLR C
    RRC A
    XCH A, B
    RRC A
    XCH A, B

    ; / 4
    CLR C
    RRC A
    XCH A, B
    RRC A
    XCH A, B
    
    ; / 8    
    CLR C
    RRC A
    XCH A, B
    RRC A
    XCH A, B
    
    ; / 16    
    CLR C
    RRC A
    XCH A, B
    RRC A
    XCH A, B

    ; / 2 samples
    CLR C
    RRC A
    XCH A, B
    RRC A
    XCH A, B

    ; / 4 samples
    CLR C
    RRC A
    XCH A, B
    RRC A
    XCH A, B

    MOV R5, A
    MOV R6, B

    MOV A, #0
    CLR C
    SUBB A, R5
    MOV R7, A
    MOV A, #0
    SUBB A, R6

    ; auto-reload now in A:R7
    MOV RCAP2H, A
    MOV RCAP2L, R7

    MOV @R0, #0x41
    INC R0
    MOV @R0, A
    INC R0
    INC R0
    INC R0    
    MOV @R0, #0x42
    INC R0
    MOV A, R7
    MOV @R0, A
    INC R0
    INC R0
    INC R0
    MOV @R0, #0x43
    INC R0
    MOV A, R3
    MOV @R0, A
    INC R0
    INC R0
    INC R0
    MOV @R0, #0x44
    INC R0
    MOV A, R4
    MOV @R0, A
    

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

; PARAM A: Address of Value to add to R4:R3
; PARAM R3: Lower bits of Addition
; PARAM R4: Higher bits of Addition
FUN_ADD16:
    ADD A, R3
    JNC NO_OVERFLOW
    ; Increment higher bits
    INC R4
NO_OVERFLOW:
    MOV R3, A
    RET

END
