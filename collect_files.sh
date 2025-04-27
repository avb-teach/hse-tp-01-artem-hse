#!/bin/bash

# Выход при любой ошибке
set -e

# Проверяем количество аргументов
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input_dir> <output_dir> [--max_depth depth]" >&2 # Выводим usage в stderr
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH=""

# Проверяем наличие параметра max_depth
if [ "$#" -eq 4 ] && [ "$3" = "--max_depth" ]; then
    MAX_DEPTH="\$4"
fi

# Проверяем существование входной директории в shell-скрипте тоже, на всякий случай
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist" >&2 # Выводим ошибку в stderr
    exit 1
fi

# Запускаем Python-скрипт с параметрами
# Python-скрипт сам обрабатывает создание выходной директории, копирование,
# логику max_depth и вывод словаря в stdout.
if [ -n "$MAX_DEPTH" ]; then
    python3 collect_files.py "$INPUT_DIR" "$OUTPUT_DIR" "$MAX_DEPTH"
else
    python3 collect_files.py "$INPUT_DIR" "$OUTPUT_DIR"
fi

# Если python3 завершится с ошибкой (ненулевой статус), set -e перехватит это,
# и shell-скрипт завершится с тем же статусом.
# Если python3 завершится успешно (статус 0), shell-скрипт также завершится успешно.
