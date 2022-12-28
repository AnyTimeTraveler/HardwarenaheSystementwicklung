NAME ram_test


;=====================
;= GLOBALE VARIABLEN =
;=====================

compare_value DATA 0x0000


;======================
;= GLOBALE KONSTANTEN =
;======================

; Diese werden nicht mitkompiliert
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

;=============
;= MAIN LOOP =
;=============

; Eigentlicher Programmcode
CSEG AT 0x0100

; LED aus machen
setb P3.5

; DPTR ist 16 Bit und wird hochgezaehlt,
; um den RAM zu addressieren
mov DPTR, #0x0000

; In einer Schleife gehen wir jetzt alle Addressen durch,
; beschreiben sie und lesen sie wieder.
; Dann wird der Wert verglichen und geprueft,
; dass der Wert passt.
loop: 
; Die niedrigen 8 Bit von DPTR wird als testwert genommen
; Wir legen sie in A, um sie an den RAM zu schicken
mov A, DPL
; Vorher wird sie noch in die Variable compare_value kopiert,
; zum spaeteren Vergleich
mov compare_value, A

; Schreibe A in den RAM
MOVX @DPTR, A
; Lese A aus dem RAM
MOVX A, @DPTR

; Compare Jump Not Equal
; Vergleiche und springe zu error,
; wenn der Wert nicht der gleiche ist
CJNE A, compare_value, error
; Zieladdresse um 1 erhoehen
INC DPTR

; Accumulator mit den 8 hohen Bits der Adresse fuellen
mov A, DPH

; Compare Jump Not Equal
; Sobald die hohen Bits 32 sind,
; sind wir bei 8192 im RAM, und somit am Ende des RAM's
; Also springen wir, bis der Wert gleich ist
CJNE A, #32, loop

; done!
; Endlosschleife
; LED an machen
clr P3.5
jmp $

error:

; infinite loop
; LED aus machen
setb P3.5
JMP $

END

