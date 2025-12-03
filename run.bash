#!/usr/bin/env bash
set -e

make -j

echo
echo

for d in 01 02 03; do
	echo "==== Day $d ===="
	"$d/main" < "$d/part1.txt"
done