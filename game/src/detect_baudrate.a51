NAME detect_baudrate    		    
       	             
$INCLUDE(macros.a51)

SEG_DETECT_BAUDRATE SEGMENT CODE

EXTRN DATA (RCAP2L, RCAP2H, T2CON)
; EXTRN IDATA (GAMESCREEN)
PUBLIC PFUN_DETECT_BAUDRATE

RSEG SEG_DETECT_BAUDRATE
PFUN_DETECT_BAUDRATE:
    USING 0

    ; MOV R0, #GAMESCREEN + 4

INVALID_MEASUREMENT:
    MOV TL1, #0
    MOV TH1, #0
    ; Basisformel:
    ; x: Timer 1 Ticks
    ; y: Timer 2 Baudrate Ticks
    ; x * 6 / 16 = y

    ; Anstatt der Multiplikation nehmen wir einfach die Zeit von 6 Tackten

    ; Einen Tackt abwarten, dann 6 Tackte abzaehlen
    JB P3.2, $
    ; Timer starten
    SETB TR1
    ; 1
    JNB P3.2, $
    JB P3.2, $
    ; 2
    JNB P3.2, $
    JB P3.2, $
    ; 3
    JNB P3.2, $
    JB P3.2, $
    ; 4
    JNB P3.2, $
    JB P3.2, $
    ; 5
    JNB P3.2, $
    JB P3.2, $
    ; 6
    JNB P3.2, $
    ; disable all interrupts for accurate measurement
    CLR EA
    JB P3.2, $
    ; Timer stoppen
    CLR TR1

    ; enable all interrupts again
    SETB EA

    ; DEBUGPRINT 0x01,TH1
    ; DEBUGPRINT 0x02,TL1

    ; Testen, ob Timer-Wert in einer Validen Range liegt

    ; MIN | MAX
    ; 600 | 1000

    ; Anstatt zu pruefen, ob die Zahlen stimmen,
    ; koennen wir einfach pruefen ob TH1 2 oder 3 ist.
    ; Dies gibt einen Werterbereich von 512 bis 1023

    MOV A, TH1
    CJNE A, #2, CHECK_3
    JMP VALID_MEASUREMENT
CHECK_3:
    CJNE A, #3, INVALID_MEASUREMENT
VALID_MEASUREMENT:

    ; Jetzt nurnoch durch 16 teilen und von 2^16 abziehen,
    ; um den Reload-Wert zu erhalten

    ; Timer reload: 2^16 - (R4:R3 / 16)

    ; Durch 16 teilen ist 4 mal shiften
    ; 4 mal shiften ist einen Nibble raus schieben

    ;    TH1    ||    TL1
    ; THH | THL || TLH | TLL
    ; wird verschoben nach:
    ;     B     ||     A
    ;  0  | THH || THL | TLH

    ; So we move values into ACC and a memory location
    MOV A, TL1
    MOV R2, TH1

    ; We swap the lower nibbles of TL with TH:
    ;     B     ||     A
    ; THH | TLL || TLH | THL
    MOV R1, #AR2
    XCHD A, @R1

    ; A now contains the right nibbles, but swapped
    ; so we swap them:
    ;     B     ||     A
    ; THH | TLL || THL | TLH
    ; The result is:
    ;     A
    ; THL | TLH
    SWAP A

    ; Now, we only need to substract to get the auto-reload value
    ; reload = 2^16 - A

    ; MOV R3, A
    ; DEBUGPRINT 0x03,R3
    
    ; backup A
    MOV B, A

    MOV A, #0
    CLR C
    SUBB A, B

    ; MOV R3, A
    ; DEBUGPRINT 0x04,R3

;     CJNE A, #0xD3, ERROR
;     JMP AAAA
; ERROR:
;     JMP $
; AAAA:

    ; write auto-reload
    MOV RCAP2H, #0xFF
    MOV RCAP2L, A

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

    ; enable serial interrupts

    ; give serial low priority
    SETB PS
    ; give screen (timer 0) high priority
    CLR PT0

    CLR PT1

    RET


END
