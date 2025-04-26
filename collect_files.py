#!/usr/bin/env python3

import os
from collections import defaultdict

def collect_files(input_dir, max_depth=None):
    """
    Собирает все файлы во всех поддиректориях, группируя по именам.
    
    Аргументы:
        input_dir (str): Путь к входной директории
        max_depth (int|None): Максимальная глубина обхода (None - без ограничений)
    
    Возвращает:
        defaultdict(set): {имя_файла: {относительные_пути}}
    """
    files_dict = defaultdict(set)
    input_dir = os.path.abspath(input_dir)
    
    if max_depth is not None and max_depth < 0:
        return defaultdict(set)
    
    for root, _, files in os.walk(input_dir):
        # Вычисляем глубину относительно input_dir
        rel_path = os.path.relpath(root, input_dir)
        current_depth = rel_path.count(os.sep) if rel_path != '.' else 0
        
        # Проверка глубины
        if max_depth is not None and current_depth >= max_depth:
            continue
            
        for file in files:
            if rel_path == '.':
                files_dict[file].add(file)
            else:
                files_dict[file].add(os.path.join(rel_path, file))
    
    return files_dict

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 collect_files.py <input_dir> [max_depth]")
        sys.exit(1)
        
    try:
        input_dir = sys.argv[1]
        max_depth = int(sys.argv[2]) if len(sys.argv) > 2 else None
    except ValueError:
        print("Error: max_depth must be an integer")
        sys.exit(1)
        
    result = collect_files(input_dir, max_depth)
    print(dict(result))