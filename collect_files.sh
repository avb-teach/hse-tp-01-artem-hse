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
if [ $# -eq 4 ] && [ "$3" == "--max_depth" ]; then
    MAX_DEPTH_ARG="\$4"
fi

# Создаем выходную директорию если её нет
mkdir -p "$OUTPUT_DIR"

# Запускаем Python-код с вашей реализацией
python3 - <<EOF
import os
import shutil
import sys
from collections import defaultdict

# Получаем аргументы из bash-переменных
input_dir = "$INPUT_DIR"
output_dir = "$OUTPUT_DIR"
max_depth = -1

if "$MAX_DEPTH_ARG":
    try:
        max_depth = int("$MAX_DEPTH_ARG")
    except ValueError:
        print("Ошибка: max_depth должен быть целым числом")
        sys.exit(1)

def copy_files(input_dir, output_dir, max_depth=-1):
    file_counts = defaultdict(int)
    
    def unique_filename(filename):
        base_name, ext = os.path.splitext(filename)
        count = file_counts[filename]
        file_counts[filename] += 1
        
        if count == 0:
            return filename
        return f"{base_name}{count}{ext}"
    
    def process_directory(current_dir, current_depth=0):
        if max_depth != -1 and current_depth > max_depth:
            rel_path = os.path.relpath(current_dir, input_dir)
            dest_path = os.path.join(output_dir, rel_path)
            
            if not os.path.exists(dest_path):
                shutil.copytree(current_dir, dest_path)
            return
            
        for item in os.listdir(current_dir):
            full_path = os.path.join(current_dir, item)
            
            if os.path.isfile(full_path):
                if max_depth != -1:
                    rel_path = os.path.relpath(current_dir, input_dir)
                    dest_dir = os.path.join(output_dir, rel_path)
                    os.makedirs(dest_dir, exist_ok=True)
                    
                    unique_name = unique_filename(item)
                    dest_path = os.path.join(dest_dir, unique_name)
                else:
                    unique_name = unique_filename(item)
                    dest_path = os.path.join(output_dir, unique_name)
                
                shutil.copy2(full_path, dest_path)
            
            elif os.path.isdir(full_path):
                if max_depth == -1 or current_depth < max_depth:
                    process_directory(full_path, current_depth + 1)
                else:
                    rel_path = os.path.relpath(full_path, input_dir)
                    dest_path = os.path.join(output_dir, rel_path)
                    if not os.path.exists(dest_path):
                        shutil.copytree(full_path, dest_path)

# Запуск функции копирования
copy_files(input_dir, output_dir, max_depth)
EOF

echo "Копирование файлов завершено"
exit 0
