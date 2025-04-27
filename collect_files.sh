#!/bin/bash

# Выход при любой ошибке
set -e

# Проверяем количество аргументов
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input_dir> <output_dir> [--max_depth depth]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH=""

# Проверяем наличие параметра max_depth
if [ "$#" -eq 4 ] && [ "$3" = "--max_depth" ]; then
    MAX_DEPTH="\$4"
fi

# Проверяем существование входной директории
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist"
    exit 1
fi

# Запускаем Python-скрипт с параметрами
# Python-скрипт сам обрабатывает создание выходной директории и копирование.
# Он также выводит словарь на стандартный вывод.
if [ -n "$MAX_DEPTH" ]; then
    python3 collect_files.py "$INPUT_DIR" "$OUTPUT_DIR" "$MAX_DEPTH"
else
    python3 collect_files.py "$INPUT_DIR" "$OUTPUT_DIR"
fi

# Python-скрипт сам возвращает 0 при успешном завершении.
# Если python3 завершится с ошибкой, `set -e` перехватит ее.
