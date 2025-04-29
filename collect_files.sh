#!/bin/bash

if [ "$#" -lt 2 ]; then
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH_FLAG=""
MAX_DEPTH=""

if [ "$#" -eq 4 ] && [ "$3" = "--max_depth" ]; then
    MAX_DEPTH_FLAG="--max_depth"
    MAX_DEPTH="\$4"
fi

python3 collect_files.py "$INPUT_DIR" "$OUTPUT_DIR" $MAX_DEPTH_FLAG $MAX_DEPTH