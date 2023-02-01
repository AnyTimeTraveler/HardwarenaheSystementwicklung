NAME game_current_piece

SEG_CURRENT_PIECE SEGMENT CODE

EXTRN DATA (CURRENT_PIECE_INDEX, CURRENT_PIECE_ROT_INDEX, CURRENT_PIECE_H_POS)
EXTRN DATA (CP_R0_L, CP_R0_M, CP_R0_R, CP_R1_L, CP_R1_M, CP_R1_R, CP_R2_L, CP_R2_M, CP_R2_R, CP_R3_L, CP_R3_M, CP_R3_R)
PUBLIC PFUN_DECOMPRESS_PIECE, PFUN_SHIFT_PIECE_LEFT, PFUN_SHIFT_PIECE_RIGHT, PFUN_ROTATE_PIECE_RIGHT, PFUN_ROTATE_PIECE_LEFT
EXTRN CODE (DAT_TETRIS_PIECES)
EXTRN NUMBER (PIECE_SIZE)

RSEG SEG_CURRENT_PIECE
PFUN_DECOMPRESS_PIECE:
    ; load compressed piece into R1 and R2
    MOV DPTR, #DAT_TETRIS_PIECES
    ; add 8 * piece index to it,
    ; to skip to the start of the correct piece
    ; since each piece is 8 bytes
    MOV A, CURRENT_PIECE_INDEX
    MOV B, #PIECE_SIZE
    MUL AB
    ; add 2 * rotation, since every rotation is 2 bytes
    ADD A, CURRENT_PIECE_ROT_INDEX
    ADD A, CURRENT_PIECE_ROT_INDEX
    ; save address in R1
    MOV R1, A
    ; get byte
    MOVC A, @A + DPTR
    ; swap adress back into A
    XCH A, R1
    ; increment to get the second byte of the piece
    INC A
    MOVC A, @A + DPTR
    MOV R2, A

    ; the compressed piece is now R2:R1

    ; Overwrite the decompressed piece
    ; first nibble of byte 0
    MOV CP_R0_L, #0
    MOV CP_R0_M, R1
    ANL CP_R0_M, #0xF0
    MOV CP_R0_R, #0
    ; second nibble of byte 0
    MOV CP_R1_L, #0
    MOV A, R1
    SWAP A
    ANL A, #0xF0
    MOV CP_R1_M, A
    MOV CP_R1_R, #0
    ; first nibble of byte 1
    MOV CP_R2_L, #0
    MOV CP_R2_M, R2
    ANL CP_R2_M, #0xF0
    MOV CP_R2_R, #0
    ; second nibble of byte 1
    MOV CP_R3_L, #0
    MOV A, R2
    SWAP A
    ANL A, #0xF0
    MOV CP_R3_M, A
    MOV CP_R3_R, #0
    MOV CURRENT_PIECE_H_POS, #8
    RET

MOVE_ROW_LEFT MACRO ROW
    CLR C
    MOV A, ROW&_R
    RLC A
    MOV ROW&_R, A
    MOV A, ROW&_M
    RLC A
    MOV ROW&_M, A
    MOV A, ROW&_L
    RLC A
    MOV ROW&_L, A
ENDM

MOVE_ROW_RIGHT MACRO ROW
    CLR C
    MOV A, ROW&_L
    RRC A
    MOV ROW&_L, A
    MOV A, ROW&_M
    RRC A
    MOV ROW&_M, A
    MOV A, ROW&_R
    RRC A
    MOV ROW&_R, A
ENDM

PFUN_SHIFT_PIECE_LEFT:
    MOVE_ROW_LEFT CP_R0
    MOVE_ROW_LEFT CP_R1
    MOVE_ROW_LEFT CP_R2
    MOVE_ROW_LEFT CP_R3
    DEC CURRENT_PIECE_H_POS
    RET

PFUN_SHIFT_PIECE_RIGHT:
    MOVE_ROW_RIGHT CP_R0
    MOVE_ROW_RIGHT CP_R1
    MOVE_ROW_RIGHT CP_R2
    MOVE_ROW_RIGHT CP_R3
    INC CURRENT_PIECE_H_POS
    RET

PFUN_ROTATE_PIECE_LEFT:
    ; make sure it stays a valid value
    MOV A, CURRENT_PIECE_ROT_INDEX
    JNZ DEC_ROT_INDEX
    ; since it also gets decremented, set it one higher
    MOV CURRENT_PIECE_ROT_INDEX, #4
DEC_ROT_INDEX:
    DEC CURRENT_PIECE_ROT_INDEX
    MOV R3, CURRENT_PIECE_H_POS
    ; load the new piece
    CALL PFUN_DECOMPRESS_PIECE
    ; shift it to the correct place
    JMP FUN_SHIFT_TO_CORRECT_H_POS

PFUN_ROTATE_PIECE_RIGHT:
    ; make sure it stays a valid value
    MOV A, CURRENT_PIECE_ROT_INDEX
    CJNE A, #3, INC_ROT_INDEX
    ; since it also gets incremented, set it one lower
    MOV CURRENT_PIECE_ROT_INDEX, #255
INC_ROT_INDEX:
    INC CURRENT_PIECE_ROT_INDEX
    MOV R3, CURRENT_PIECE_H_POS
    ; load the new piece
    CALL PFUN_DECOMPRESS_PIECE

FUN_SHIFT_TO_CORRECT_H_POS:
    ; shift it to the correct place
    MOV A, R3
    CLR C
    SUBB A, #8
    JC SMALLER
    JNZ LARGER
EQUAL:
    JMP ROT_LEFT_DONE
LARGER:
    CALL PFUN_SHIFT_PIECE_RIGHT
    MOV A, R3
    CJNE A, CURRENT_PIECE_H_POS, LARGER
    JMP ROT_LEFT_DONE
SMALLER:
    CALL PFUN_SHIFT_PIECE_LEFT
    MOV A, R3
    CJNE A, CURRENT_PIECE_H_POS, SMALLER
ROT_LEFT_DONE:
    RET

END
