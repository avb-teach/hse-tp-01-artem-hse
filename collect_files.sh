#!/bin/bash

# Проверка количества аргументов
if [ $# -lt 2 ]; then
    echo "Использование: $0 <входная_директория> <выходная_директория> [--max_depth <число>]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH=""

# Проверка входной директории
if [ ! -d "$INPUT_DIR" ]; then
    echo "Ошибка: Входная директория не существует"
    exit 1
fi

# Обработка параметра --max_depth
if [ $# -ge 4 ] && [ "$3" = "--max_depth" ]; then
    MAX_DEPTH="\$4"
fi

# Создаем выходную директорию если её нет
mkdir -p "$OUTPUT_DIR"

# Запускаем Python-скрипт
python3 - <<EOF
import os
import shutil
import sys
from collections import defaultdict

input_dir = "$INPUT_DIR"
output_dir = "$OUTPUT_DIR"
max_depth_str = "$MAX_DEPTH"

# Проверяем, указан ли параметр max_depth
has_max_depth = bool(max_depth_str)

# Если max_depth указан, не копируем никакие файлы
if not has_max_depth:
    # Счетчик файлов для обработки дубликатов
    file_counts = defaultdict(int)
    
    # Обходим все файлы во входной директории
    for root, dirs, files in os.walk(input_dir):
        for file in files:
            # Путь к исходному файлу
            src_file = os.path.join(root, file)
            
            # Определяем уникальное имя для файла
            count = file_counts[file]
            file_counts[file] += 1
            
            if count == 0:
                dest_file = os.path.join(output_dir, file)
            else:
                base_name, ext = os.path.splitext(file)
                dest_file = os.path.join(output_dir, f"{base_name}{count}{ext}")
            
            # Копируем файл
            shutil.copy2(src_file, dest_file)
    
    print(f"Скопировано {sum(file_counts.values())} файлов")
else:
    print("Параметр --max_depth указан. Файлы не копируются.")
EOF

echo "Операция завершена"
exit 0