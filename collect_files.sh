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

# Счетчик файлов для обработки дубликатов
file_counts = defaultdict(int)

# Определяем, используется ли ограничение max_depth
using_max_depth = False
max_depth = None
if max_depth_str:
    try:
        max_depth = int(max_depth_str)
        using_max_depth = True
    except ValueError:
        print("Ошибка: max_depth должен быть целым числом")
        sys.exit(1)

def get_current_depth(path):
    """Определяем глубину пути относительно входной директории"""
    rel_path = os.path.relpath(path, input_dir)
    if rel_path == ".":
        return 0
    return rel_path.count(os.sep) + 1

def process_directory(dir_path):
    """Рекурсивно обрабатывает директорию"""
    current_depth = get_current_depth(dir_path)
    
    # Проверяем, превышает ли текущая глубина max_depth
    if using_max_depth and current_depth > max_depth:
        return
        
    # Обрабатываем файлы в текущей директории
    for item in os.listdir(dir_path):
        item_path = os.path.join(dir_path, item)
        
        if os.path.isfile(item_path):
            if using_max_depth:
                # С max_depth: создаем структуру директорий
                rel_path = os.path.relpath(dir_path, input_dir)
                if rel_path == ".":
                    dest_file = os.path.join(output_dir, item)
                else:
                    dest_dir = os.path.join(output_dir, rel_path)
                    os.makedirs(dest_dir, exist_ok=True)
                    dest_file = os.path.join(dest_dir, item)
            else:
                # Без max_depth: копируем с уникальными именами
                count = file_counts[item]
                file_counts[item] += 1
                
                if count == 0:
                    dest_file = os.path.join(output_dir, item)
                else:
                    base_name, ext = os.path.splitext(item)
                    dest_file = os.path.join(output_dir, f"{base_name}{count}{ext}")
            
            # Копируем файл
            shutil.copy2(item_path, dest_file)
        
        elif os.path.isdir(item_path):
            # Рекурсивно обрабатываем поддиректорию
            process_directory(item_path)

# Начинаем обработку от корневой директории
process_directory(input_dir)
EOF

echo "Копирование завершено"
exit 0
