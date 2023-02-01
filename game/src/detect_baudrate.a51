NAME detect_baudrate    		    
       	             
$INCLUDE(macros.a51)

SEG_DETECT_BAUDRATE SEGMENT CODE

EXTRN CODE (PFUN_SERIAL_WRITE)
EXTRN DATA (RCAP2L, RCAP2H, T2CON)
EXTRN BIT (IN_KEYBOARD_DATA, OUT_KEYBOARD, OUT_SCREEN)
PUBLIC PFUN_DETECT_BAUDRATE

RSEG SEG_DETECT_BAUDRATE
PFUN_DETECT_BAUDRATE:
    ; for debugging
    SETB OUT_KEYBOARD
    SETB OUT_SCREEN
INVALID_MEASUREMENT:
    MOV TL1, #0
    MOV TH1, #0
    ; Basisformel:
    ; x: Timer 1 Ticks
    ; y: Timer 2 Baudrate Ticks
    ; x * 6 / 16 = y

    ; Anstatt der Multiplikation nehmen wir einfach die Zeit von 6 Tackten

    ; Einen Tackt abwarten, dann 6 Tackte abzaehlen
    JNB IN_KEYBOARD_DATA, $
    JB IN_KEYBOARD_DATA, $
    JB IN_KEYBOARD_DATA, $
    ; disable all interrupts for accurate measurement
    CLR EA
    ; Timer starten
    SETB TR1
    ; 1
    JNB IN_KEYBOARD_DATA, $
    JB IN_KEYBOARD_DATA, $
    ; 2
    JNB IN_KEYBOARD_DATA, $
    JB IN_KEYBOARD_DATA, $
    ; 3
    JNB IN_KEYBOARD_DATA, $
    JB IN_KEYBOARD_DATA, $
    ; 4
    JNB IN_KEYBOARD_DATA, $
    JB IN_KEYBOARD_DATA, $
    ; 5
    JNB IN_KEYBOARD_DATA, $
    JB IN_KEYBOARD_DATA, $
    ; 6
    JNB IN_KEYBOARD_DATA, $
    JB IN_KEYBOARD_DATA, $
    ; Timer stoppen
    CLR TR1

    ; enable all interrupts again
    SETB EA

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
    MOV R1, TH1

    ; We swap the lower nibbles of TL with TH:
    ;     B     ||     A
    ; THH | TLL || TLH | THL
    XCHD A, @R1

    ; ACC now contains the right nibbles, but swapped
    ; so we swap them:
    ;     B     ||     A
    ; THH | TLL || THL | TLH
    ; The result is:
    ;     A
    ; THL | TLH
    SWAP A

    ; Now, we only need to substract to get the auto-reload value
    ; reload = 2^16 - A
    
    ; backup A
    MOV B, A

    MOV A, #0
    CLR C
    SUBB A, B

    ;CALL PFUN_SERIAL_WRITE
    ; TODO: remove multiple writes, when confirmed that ACC isn't being changed
    ;CALL PFUN_SERIAL_WRITE
    ;CALL PFUN_SERIAL_WRITE

    ; write auto-reload
    MOV RCAP2H, #0xFF
    MOV RCAP2L, A

    ; for debugging
    CLR OUT_KEYBOARD
    CLR OUT_SCREEN
    RET


END
