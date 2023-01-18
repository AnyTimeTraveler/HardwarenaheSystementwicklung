#!/usr/bin/env sh

set -e

KEIL_PATH="../../Programme/Keil/C51/BIN"
# KEIL_PATH="$HOME/.wine/drive_c/Keil_v5/C51/BIN"
MAIN="game"
OUPTUT_PATH="./out/"
SRC_FILES="allocations_idata allocations_xdata gamedata keyboard interrupts detect_baudrate screen setup"

function compile_file {
    file="$1"
    if ! wine "$KEIL_PATH/A51.EXE" "$file".a51 > /dev/null 2> /dev/null; then
        grep -B 3 '\*\*\* ERROR' "$file.LST"
        clean_byproducts
        exit 1
    fi
}

function clean_output {
    test -f "$MAIN.hex" && rm "$MAIN.hex"
    test -d "$OUPTUT_PATH" && rm -rf "$OUPTUT_PATH"
    cp -rf src/ "$OUPTUT_PATH"
}

function clean_byproducts {
    rm ./*.a51
    rm ./*.OBJ
}

function generate_lnp {
    for file in $SRC_FILES; do
        echo "\"$file.obj\"," >> "$MAIN.lnp"
    done
    echo "\"$MAIN.obj\" " >> "$MAIN.lnp"
    echo "TO \"$MAIN\" " >> "$MAIN.lnp"
    echo "RAMSIZE(256) " >> "$MAIN.lnp" 
    echo "XDATA( 0X0000-0X20FF,0X6000-0X60FF )" >> "$MAIN.lnp"
}

clean_output
cd "$OUPTUT_PATH"
generate_lnp

for file in $SRC_FILES; do
    compile_file "$file"
done
compile_file "$MAIN"
wine "$KEIL_PATH/BL51.EXE" "@$MAIN.lnp" | grep 'Program Size:' -A 1
! grep -A 2 "\*\*\* WARNING" "$MAIN.M51"
! grep -A 2 "\*\*\* ERROR" "$MAIN.M51"
wine "$KEIL_PATH/OH51.EXE" "$MAIN" | grep 'OBJECT TO HEX CONVERSION COMPLETED.'
clean_byproducts
cd - > /dev/null
cp "$OUPTUT_PATH/$MAIN.hex" ./
echo "Compile complete! :)"
