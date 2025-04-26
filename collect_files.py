#!/usr/bin/env python3

import os
from collections import defaultdict
import shutil
import sys

def collect_files(input_dir, output_dir, max_depth=None):
    """
    Собирает файлы с учетом максимальной глубины.
    
    Args:
        input_dir (str): Входная директория
        output_dir (str): Выходная директория
        max_depth (int, optional): Максимальная глубина
    
    Returns:
        defaultdict: Словарь с файлами
    """
    result = defaultdict(set)
    
    # Создаем выходную директорию
    os.makedirs(output_dir, exist_ok=True)
    
    # Получаем абсолютный путь входной директории
    input_dir = os.path.abspath(input_dir)
    base_depth = len(input_dir.rstrip(os.sep).split(os.sep))
    
    for root, _, files in os.walk(input_dir):
        # Вычисляем текущую глубину
        current_depth = len(root.rstrip(os.sep).split(os.sep)) - base_depth
        
        # Пропускаем, если глубина превышает max_depth
        if max_depth is not None and current_depth > max_depth:
            continue
            
        for file in files:
            src_path = os.path.join(root, file)
            dest_file = file
            
            # Создаем уникальное имя если файл существует
            counter = 1
            while os.path.exists(os.path.join(output_dir, dest_file)):
                name, ext = os.path.splitext(file)
                dest_file = f"{name}_{counter}{ext}"
                counter += 1
            
            # Копируем файл
            dest_path = os.path.join(output_dir, dest_file)
            shutil.copy2(src_path, dest_path)
            
            # Добавляем в результат
            rel_path = os.path.relpath(root, input_dir)
            if rel_path == '.':
                result[file].add(dest_file)
            else:
                result[file].add(os.path.join(rel_path, dest_file))
    
    return result

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 collect_files.py input_dir output_dir [max_depth]")
        sys.exit(1)
    
    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    max_depth = None
    
    if len(sys.argv) > 3:
        try:
            max_depth = int(sys.argv[3])
        except ValueError:
            print("Error: max_depth must be an integer")
            sys.exit(1)
    
    collect_files(input_dir, output_dir, max_depth)
