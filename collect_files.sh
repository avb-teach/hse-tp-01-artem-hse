#!/bin/bash

# Проверка количества аргументов
if [ $# -lt 2 ]; then
    echo "Использование: $0 <входная_директория> <выходная_директория> [--max_depth <число>]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH=-1  # По умолчанию без ограничения глубины

# Проверка входной директории
if [ ! -d "$INPUT_DIR" ]; then
    echo "Ошибка: Входная директория не существует"
    exit 1
fi

# Обработка параметра --max_depth
if [ $# -eq 4 ] && [ "$3" = "--max_depth" ]; then
    if [[ "$4" =~ ^[0-9]+$ ]]; then
        MAX_DEPTH=\$4
    else
        echo "Ошибка: max_depth должен быть целым числом"
        exit 1
    fi
fi

# Создаем выходную директорию если её нет
mkdir -p "$OUTPUT_DIR"

# Запускаем Python-скрипт
python3 <<EOF
import os
import shutil
import sys
from collections import defaultdict

input_dir = "$INPUT_DIR"
output_dir = "$OUTPUT_DIR"
max_depth = $MAX_DEPTH

# Используем словарь для отслеживания дубликатов имен файлов
file_counts = defaultdict(int)

def copy_files(input_dir, output_dir, max_depth):
    for root, dirs, files in os.walk(input_dir):
        # Определяем относительный путь
        rel_path = os.path.relpath(root, input_dir)
        
        # Вычисляем текущую глубину
        current_depth = 0 if rel_path == '.' else rel_path.count(os.sep) + 1
        
        # Если превышен max_depth, копируем всю директорию и прекращаем обход
        if max_depth != -1 and current_depth > max_depth:
            # Копируем только если директория еще не скопирована
            if rel_path != '.':
                dest_dir = os.path.join(output_dir, rel_path)
                if not os.path.exists(dest_dir):
                    parent_dir = os.path.dirname(dest_dir)
                    if parent_dir and not os.path.exists(parent_dir):
                        os.makedirs(parent_dir)
                    shutil.copytree(root, dest_dir)
            
            # Удаляем все поддиректории из списка, чтобы os.walk их не обрабатывал
            dirs.clear()
            continue
        
        # Обрабатываем файлы в текущей директории
        for file in files:
            src_file = os.path.join(root, file)
            
            if max_depth != -1:
                # С указанным max_depth сохраняем структуру каталогов
                if rel_path == '.':
                    dest_dir = output_dir
                else:
                    dest_dir = os.path.join(output_dir, rel_path)
                    if not os.path.exists(dest_dir):
                        os.makedirs(dest_dir)
                
                dest_file = os.path.join(dest_dir, file)
                shutil.copy2(src_file, dest_file)
            else:
                # Без max_depth копируем все файлы в корень с уникальными именами
                base_name, ext = os.path.splitext(file)
                count = file_counts[file]
                file_counts[file] += 1
                
                if count == 0:
                    dest_name = file
                else:
                    dest_name = f"{base_name}{count}{ext}"
                
                dest_file = os.path.join(output_dir, dest_name)
                shutil.copy2(src_file, dest_file)

# Запускаем функцию копирования
copy_files(input_dir, output_dir, max_depth)
EOF

echo "Копирование файлов завершено"
exit 0