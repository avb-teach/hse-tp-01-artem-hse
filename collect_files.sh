#!/bin/bash

# Проверка количества аргументов
if [ $# -lt 2 ]; then
    echo "Использование: $0 <входная_директория> <выходная_директория> [--max_depth <число>]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH_ARG=""

# Проверка входной директории
if [ ! -d "$INPUT_DIR" ]; then
    echo "Ошибка: Входная директория не существует"
    exit 1
fi

# Обработка параметра --max_depth
if [ $# -ge 4 ] && [ "$3" == "--max_depth" ]; then
    MAX_DEPTH_ARG="\$4"
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
if "$MAX_DEPTH_ARG":
    try:
        max_depth = int("$MAX_DEPTH_ARG")
    except ValueError:
        print("Ошибка: max_depth должен быть целым числом")
        sys.exit(1)

# Счетчик для одинаковых имен файлов
file_counts = defaultdict(int)

def process_directory(current_dir, current_depth=0):
    # Проверка на max_depth
    if max_depth is not None and current_depth > max_depth:
        # Копируем директорию целиком со всей вложенной структурой
        rel_path = os.path.relpath(current_dir, input_dir)
        dest_dir = os.path.join(output_dir, rel_path)
        os.makedirs(os.path.dirname(dest_dir), exist_ok=True)
        if not os.path.exists(dest_dir):
            shutil.copytree(current_dir, dest_dir)
        return

    # Обрабатываем все файлы и директории в текущей директории
    for item in os.listdir(current_dir):
        item_path = os.path.join(current_dir, item)
        
        if os.path.isfile(item_path):
            # Обработка файла
            if max_depth is not None:
                # Если указан max_depth, сохраняем структуру каталогов
                rel_path = os.path.relpath(current_dir, input_dir)
                dest_dir = os.path.join(output_dir, rel_path)
                os.makedirs(dest_dir, exist_ok=True)
                dest_path = os.path.join(dest_dir, item)
            else:
                # Иначе копируем в корень с уникальными именами
                base_name, ext = os.path.splitext(item)
                count = file_counts[item]
                file_counts[item] += 1
                
                if count > 0:
                    dest_name = f"{base_name}{count}{ext}"
                else:
                    dest_name = item
                    
                dest_path = os.path.join(output_dir, dest_name)
            
            # Копируем файл с сохранением атрибутов
            shutil.copy2(item_path, dest_path)
            
        elif os.path.isdir(item_path):
            # Рекурсивно обрабатываем подкаталог
            process_directory(item_path, current_depth + 1)

# Запускаем обработку от корневой директории
process_directory(input_dir)
EOF

echo "Копирование файлов завершено"
exit 0