NAME display_test


;=====================
;= GLOBALE VARIABLEN =
;=====================

counter DATA 0x0000

MAX_RAM_ADDR EQU 8192



;================
;= RESET VEKTOR =
;================

; Programmstart hier
CSEG AT 0x0000
; Aus dem Interrupt-Vektor raus springen
; Der Vektor sollte bis 0x33 gehen
; Sicherere ist es, ein Wenig hoeher zu springen.
JMP 0x0100

CSEG AT 0x0100

;===============
;= STACK SETUP =
;===============

; move stack to the indirect addressed area, so the other register banks are free
; normally, the stack starts at 0x07, which is the start of the second register bank
MOV SP, #0xFF


;===============
;= TIMER SETUP =
;===============

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


;=============
;= MAIN LOOP =
;=============

mov DPTR, #0x0000

loop: 
mov A, DPL
mov counter, A

MOVX @DPTR, A
MOVX A, @DPTR
CJNE A, counter, error
INC DPTR

mov A, DPH
CJNE A, #32, loop

; done!
jmp $

error:

; infinite loop
JMP $



;===============
;= TIMER 0 ISR =
;===============

; Code Segment an Stelle des Timer 0 Interrupts
CSEG AT 0x000B
; Wechsel auf die 2. Registerbank
SETB RS0
; Keine Instruktion. Der Assembler muss auch wissen,
; dass ab hier die 2. Registerbank verwendet wird.
USING 2

; R0 ist unser Zaehler
; Wir erhalten 25,43 Interrupts pro Sekunde
; Da wir die LED nur alle halbe Sekunde blinken lassen,
; muessen wir also Interrupts zaehlen
INC R0


; Wenn R0 auf 0 um
CJNE R0, #13, skip
jnb P3.5, setled
clr P3.5
jmp skip
setled:
setb P3.5
skip:

; Wechsel zurueck auf die 1. Registerbank
CLR RS0
USING 1
RETI


END
