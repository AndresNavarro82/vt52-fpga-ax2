#!/bin/sh

FILE=mda

if [ $# -ge 1 ]; then
    echo "Usage: $0 "
    exit -1
fi

if ! grep -q "(\*.*LOC.*\*)" $FILE.v; then
    echo "$FILE.v does not have LOC constraints for tinyfpga_a."
    exit -2
fi

if [ ! -z ${TRELLIS_DB+x} ]; then
    DB_ARG="--db $TRELLIS_DB"
fi

set -ex

${YOSYS:-yosys} -p "synth_machxo2 -json $FILE.json" $FILE.v
${NEXTPNR:-nextpnr-machxo2} --1200 --package QFN32 --no-iobs --json $FILE.json --textcfg $FILE.txt
ecppack --compress $DB_ARG $FILE.txt $FILE.bit
tinyproga -b $FILE.bit
