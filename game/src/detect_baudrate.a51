NAME detect_baudrate

EXTRN NUMBER (REGISTER_BANK_2_BEGIN)
PUBLIC PJMPI_TIMER_ALREADY_RUNNING

CSEG AT 0x0030
PJMPI_TIMER_ALREADY_RUNNING:
    ; Timer-Wert an Adresse in R2 speichern
    MOV @R1, TL1
    ; Timer-Wert zuruecksetzen
    MOV TL1, #0
    INC R1
    ; Wenn alle 8 Register voll sind
    CJNE R1, #REGISTER_BANK_2_BEGIN, RETURN
    ; Interrupt deaktivieren
    CLR ET1
RETURN:
    RETI


SEG_DETECT_BAUDRATE SEGMENT CODE

EXTRN NUMBER (REGISTER_BANK_1_BEGIN)
EXTRN BIT (BIT_BAUDRATE_DETECTING, BIT_BAUD_ERROR_FLAG)

RSEG SEG_DETECT_BAUDRATE
    SETB BIT_BAUDRATE_DETECTING
    ; Interrupt INT0 scharf schalten
    ; Der Interrupt startet dann Timer 1

    ; Adresse wo die Werte abgespeichert werden sollen
    MOV R1, #REGISTER_BANK_1_BEGIN

    ; Timer 1 Interrupt aktivieren
    SETB ET1
    ; Warte, bis Externer Interrupt 1 deaktiviert wurde
    JB ET1, $
    JNB BIT_BAUD_ERROR_FLAG, SAMPLE_GATHERING_OK
    ; Retry
    JMP SEG_DETECT_BAUDRATE

    CLR BIT_BAUDRATE_DETECTING
    RET

SAMPLE_GATHERING_OK:
    MOV R1, #REGISTER_BANK_1_BEGIN
    MOV A, @R1
    INC R1
ADD_TIMES:    
    CALL FUN_ADD16
    INC R1
    CJNE R1, #REGISTER_BANK_2_BEGIN, ADD_TIMES
    


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
