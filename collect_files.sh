#!/bin/bash

# Проверка аргументов
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 input_dir output_dir [--max_depth depth]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH=""

# Обработка --max_depth
if [ "$#" -eq 4 ] && [ "$3" = "--max_depth" ]; then
    MAX_DEPTH="\$4"
fi

# Проверка существования входной директории
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory does not exist"
    exit 1
fi

# Создание выходной директории
mkdir -p "$OUTPUT_DIR"

# Запуск Python скрипта
if [ -n "$MAX_DEPTH" ]; then
    python3 collect_files.py "$INPUT_DIR" "$OUTPUT_DIR" "$MAX_DEPTH"
else
    python3 collect_files.py "$INPUT_DIR" "$OUTPUT_DIR"
fi

exit 0