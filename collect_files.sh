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

input_dir = "$INPUT_DIR"
output_dir = "$OUTPUT_DIR"
max_depth_str = "$MAX_DEPTH"

# Проверяем наличие max_depth
max_depth = None
if max_depth_str:
    try:
        max_depth = int(max_depth_str)
    except ValueError:
        print("Ошибка: max_depth должен быть целым числом")
        sys.exit(1)

def rel_depth(path):
    """Вычисляет глубину пути относительно входной директории"""
    rel_path = os.path.relpath(path, input_dir)
    if rel_path == ".":
        return 0
    return rel_path.count(os.sep) + 1

def copy_files_with_depth():
    """Копирует файлы согласно указанной max_depth"""
    for root, dirs, files in os.walk(input_dir):
        depth = rel_depth(root)
        
        # Если max_depth задан и превышен, пропускаем поддиректории
        if max_depth is not None and depth > max_depth:
            dirs[:] = []  # Не углубляемся дальше
            continue

        for file in files:
            src_file = os.path.join(root, file)
            rel_path = os.path.relpath(root, input_dir)
            
            # Создаем структуру директорий до заданной глубины
            if rel_path == ".":
                dest_dir = output_dir
            else:
                dest_dir = os.path.join(output_dir, rel_path)
            
            os.makedirs(dest_dir, exist_ok=True)
            
            # Копируем файл
            dest_file = os.path.join(dest_dir, file)
            shutil.copy2(src_file, dest_file)

def copy_all_files_to_root():
    """Копирует все файлы в корень выходной директории"""
    for root, _, files in os.walk(input_dir):
        for file in files:
            src_file = os.path.join(root, file)
            dest_file = os.path.join(output_dir, file)
            shutil.copy2(src_file, dest_file)

# Если max_depth указан, копируем с учетом глубины
if max_depth is not None:
    copy_files_with_depth()
else:
    # Если max_depth не указан, копируем все файлы в корень
    copy_all_files_to_root()

EOF

echo "Копирование завершено"
exit 0