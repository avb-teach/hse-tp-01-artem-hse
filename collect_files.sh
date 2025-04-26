#!/bin/bash

# Проверяем количество аргументов
if [ "$#" -lt 2 ]; then
    echo "Использование: $0 input_dir output_dir"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="\$2"

# Проверяем существование входной директории
if [ ! -d "$INPUT_DIR" ]; then
    echo "Ошибка: Входная директория не существует"
    exit 1
fi

# Создаем выходную директорию, если её нет
mkdir -p "$OUTPUT_DIR"

# Запускаем Python скрипт для копирования файлов
python3 - <<EOF
import os
import shutil

input_dir = "$INPUT_DIR"
output_dir = "$OUTPUT_DIR"

# Обходим все файлы в директории и поддиректориях
for root, _, files in os.walk(input_dir):
    for file in files:
        # Получаем полный путь к исходному файлу
        source_file = os.path.join(root, file)
        # Копируем файл в выходную директорию
        destination_file = os.path.join(output_dir, file)
        
        # Если файл с таким именем уже существует, добавляем числовой суффикс
        counter = 1
        base_name, ext = os.path.splitext(file)
        while os.path.exists(destination_file):
            destination_file = os.path.join(output_dir, f"{base_name}_{counter}{ext}")
            counter += 1
            
        shutil.copy2(source_file, destination_file)

print("Копирование завершено")
EOF

exit 0
