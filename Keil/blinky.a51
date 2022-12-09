NAME blinky


;================
;= RESET VEKTOR =
;================

; Programmstart hier
CSEG AT 0x0000
; Aus dem Interrupt-Vektor raus springen
; Der Vektor sollte bis 0x33 gehen
; Sicherere ist es, ein Wenig hoeher zu springen.
JMP 0x0100


;=============
;= MAIN LOOP =
;=============

; Eigentlicher Programmcode
CSEG AT 0x0100

; Timer 1 $ Timer 0
; MODE BITS
; GATE | Counter/Timer | Mode 1 | Mode 0
; 
; Mode 00: 13 Bit Timer, 5 Bit Prescaler
; Mode 01: 16 Bit Timer, 0 Bit Prescaler
; Mode 11: 2x 8 Bit Timer (separat)
; 
mov TMOD, #0001$0001b

; Interrupts allgemein aktivieren
SETB EA

; Timer 0 Interrupt aktivieren
SETB ET0

; Timer 0 Run aktivieren
SETB TR0

; Timer Setup durch!
; infinite loop
JMP $


;===============
;= TIMER 0 ISR =
;===============

; Code Segment an Stelle des Timer 0 Interrupts
CSEG AT 0x000B

; R0 ist unser Zaehler
; Wir erhalten 25,43 Interrupts pro Sekunde
; Da wir die LED nur alle halbe Sekunde blinken lassen,
; muessen wir also Interrupts zaehlen
INC R0


; Wenn R0 auf 0 umspringt, togglen wir die LED
; Ansonsten wird ueberprungen
CJNE R0, #13, skip
; Check, ob P3.5 Bit gesetzt ist
jnb P3.5, setled
; Clear P3.5
clr P3.5
; Fertig
jmp skip

; Das Bit war nicht gesetzt
setled:
; Bit P3.5 setzen
setb P3.5

; Das Skip-Label zum UEberspringen
skip:

; Aus dem Interrupt returnen
RETI

; Ende des Assembler Programms
END
