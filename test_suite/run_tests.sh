#!/bin/sh

END_STRING="======= TESTS END"
PROJECT_PATH="test_suite/"
GODOT_BIN="test_suite/bin/godot.elf"
OUT=`$GODOT_BIN --headless --debug --path test_suite/ -s res://runner.gd`
RUN=`echo $OUT | grep "$END_STRING"`
RES=`echo $OUT | grep FAILURE`

echo "$OUT"

if [ -z "$RUN" ]; then
	echo "Run failed!"
	exit 1
fi

if [ -z "$RES" ]; then
	echo "Tests passed!"
	exit 0
fi
echo "Tests failed!"
exit 1
