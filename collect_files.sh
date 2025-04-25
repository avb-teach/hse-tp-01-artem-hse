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
if [ $# -ge 4 ] && [ "$3" == "--max_depth" ]; then
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
max_depth = None
if "$MAX_DEPTH":
    try:
        max_depth = int("$MAX_DEPTH")
    except ValueError:
        print("Ошибка: max_depth должен быть целым числом")
        sys.exit(1)

def copy_files(input_dir, output_dir, max_depth=None):
    file_counts = defaultdict(int)
    
    def process_directory(current_dir, current_depth=0):
        # Если достигли max_depth, копируем всю директорию целиком
        if max_depth is not None and current_depth > max_depth:
            rel_path = os.path.relpath(current_dir, input_dir)
            target_dir = os.path.join(output_dir, rel_path)
            if not os.path.exists(target_dir):
                os.makedirs(os.path.dirname(target_dir), exist_ok=True)
                shutil.copytree(current_dir, target_dir)
            return
        
        for item in os.listdir(current_dir):
            item_path = os.path.join(current_dir, item)
            
            # Обработка файла
            if os.path.isfile(item_path):
                if max_depth is not None:
                    # С max_depth сохраняем структуру каталогов
                    rel_dir = os.path.relpath(current_dir, input_dir)
                    dest_dir = os.path.join(output_dir, rel_dir)
                    os.makedirs(dest_dir, exist_ok=True)
                    dest_path = os.path.join(dest_dir, item)
                else:
                    # Все файлы в один каталог с уникальными именами
                    base_name, ext = os.path.splitext(item)
                    count = file_counts[item]
                    file_counts[item] += 1
                    
                    if count > 0:
                        dest_name = f"{base_name}{count}{ext}"
                    else:
                        dest_name = item
                        
                    dest_path = os.path.join(output_dir, dest_name)
                
                shutil.copy2(item_path, dest_path)
            
            # Обработка подкаталога
            elif os.path.isdir(item_path):
                process_directory(item_path, current_depth + 1)

# Запускаем функцию копирования
process_directory(input_dir)

copy_files(input_dir, output_dir, max_depth)
EOF

echo "Копирование файлов завершено"
exit 0
