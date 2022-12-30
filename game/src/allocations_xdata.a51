NAME allocations_allocations


; =============
; == EXT RAM ==
; =============

PUBLIC XRAM, LED_MATRIX_0, LED_MATRIX_1, LED_MATRIX_2

XSEG AT 0
XRAM:           DS 0x2000

XSEG AT 0x2000
LED_MATRIX_0:   DS 0x48

XSEG AT 0x2100
LED_MATRIX_1:   DS 0x48

XSEG AT 0x2200
LED_MATRIX_2:   DS 0x48

END
