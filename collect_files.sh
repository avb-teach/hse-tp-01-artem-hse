#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input_dir> <output_dir> [--max_depth <depth>]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH=""

# Парсинг --max_depth
if [ "$#" -ge 4 ] && [ "$3" == "--max_depth" ]; then
    MAX_DEPTH="\$4"
fi

# Создание выходной директории
mkdir -p "$OUTPUT_DIR"

# Запуск Python-скрипта с сохранением результатов
python3 collect_files.py "$INPUT_DIR" $MAX_DEPTH

# Копирование файлов
if [ -z "$MAX_DEPTH" ]; then
    find "$INPUT_DIR" -type f -exec cp --parents {} "$OUTPUT_DIR" \;
else
    find "$INPUT_DIR" -maxdepth "$MAX_DEPTH" -type f -exec cp --parents {} "$OUTPUT_DIR" \;
fi
