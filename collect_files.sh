#!/bin/bash

# Проверка количества аргументов
if [ "$#" -lt 2 ]; then
    echo "Использование: $0 input_dir output_dir [--max_depth depth]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH_FLAG=""
MAX_DEPTH=""

# Обработка опционального параметра --max_depth
if [ "$#" -eq 4 ] && [ "$3" = "--max_depth" ]; then
    MAX_DEPTH_FLAG="--max_depth"
    MAX_DEPTH="\$4"
fi

# Вызов Python-скрипта
python3 collect_files.py "$INPUT_DIR" "$OUTPUT_DIR" $MAX_DEPTH_FLAG $MAX_DEPTH
