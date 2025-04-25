#!/bin/bash

# Проверка количества аргументов
if [ $# -lt 2 ]; then
    echo "Использование: $0 <входная_директория> <выходная_директория> [--max_depth <число>]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
MAX_DEPTH=-1

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

# Обработка max_depth
max_depth = None
if max_depth_str and max_depth_str != "-1":
    try:
        max_depth = int(max_depth_str)
    except ValueError:
        print("Ошибка: max_depth должен быть целым числом")
        sys.exit(1)

# Счетчик файлов для обработки дубликатов
file_counts = defaultdict(int)

# Основной алгоритм копирования
def copy_files():
    for root, dirs, files in os.walk(input_dir):
        # Вычисляем текущую глубину
        rel_path = os.path.relpath(root, input_dir)
        depth = 0 if rel_path == "." else rel_path.count(os.sep) + 1
        
        # Проверяем ограничение по глубине
        if max_depth is not None and depth > max_depth:
            continue  # Пропускаем директории глубже max_depth
            
        for file in files:
            src_file = os.path.join(root, file)
            
            # Определяем путь назначения в зависимости от наличия max_depth
            if max_depth is not None:
                # Сохраняем структуру каталогов до max_depth
                if rel_path == ".":
                    # Файлы из корневой директории
                    dest_file = os.path.join(output_dir, file)
                else:
                    # Создаем соответствующую структуру каталогов
                    dest_dir = os.path.join(output_dir, rel_path)
                    os.makedirs(dest_dir, exist_ok=True)
                    dest_file = os.path.join(dest_dir, file)
            else:
                # Без max_depth - все файлы в корень с уникальными именами
                base_name, ext = os.path.splitext(file)
                count = file_counts[file]
                file_counts[file] += 1
                
                if count == 0:
                    dest_file = os.path.join(output_dir, file)
                else:
                    dest_file = os.path.join(output_dir, f"{base_name}{count}{ext}")
            
            # Копируем файл с сохранением атрибутов
            shutil.copy2(src_file, dest_file)

# Запускаем функцию копирования
copy_files()
EOF

echo "Копирование завершено"
exit 0
