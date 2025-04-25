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
exact_depth = None
if max_depth_str:
    try:
        exact_depth = int(max_depth_str)
    except ValueError:
        print("Ошибка: max_depth должен быть целым числом")
        sys.exit(1)

def get_depth(path):
    """Определяем глубину пути относительно входной директории"""
    rel_path = os.path.relpath(path, input_dir)
    if rel_path == ".":
        return 0
    return rel_path.count(os.sep) + 1

def copy_files():
    """Копирует файлы согласно заданным параметрам"""
    for root, dirs, files in os.walk(input_dir):
        current_depth = get_depth(root)
        
        # Если задан exact_depth, копируем только файлы на точной глубине
        # Иначе - копируем все файлы в корень с уникальными именами
        if exact_depth is not None:
            # Копируем только файлы на точно указанной глубине
            if current_depth == exact_depth:
                for file in files:
                    src_file = os.path.join(root, file)
                    
                    # Создаем структуру директорий как в исходной
                    rel_path = os.path.relpath(root, input_dir)
                    dest_dir = os.path.join(output_dir, rel_path)
                    os.makedirs(dest_dir, exist_ok=True)
                    dest_file = os.path.join(dest_dir, file)
                    
                    # Копируем файл
                    shutil.copy2(src_file, dest_file)
        else:
            # Без max_depth: копируем все файлы в корень с уникальными именами
            for file in files:
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

# Запускаем функцию копирования
copy_files()
EOF

echo "Копирование завершено"
exit 0
