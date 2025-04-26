#!/usr/bin/env python3

import os
from collections import defaultdict

def collect_files(input_dir, max_depth=None):
    """
    Собирает все файлы в указанной директории и её поддиректориях, группируя по именам.

    Args:
        input_dir (str): Входная директория для сбора файлов.
        max_depth (int, optional): Максимальная глубина вложенности (0 означает только корень).

    Returns:
        defaultdict(set): Словарь формата {имя файла: пути к файлам}.
    """
    files_dict = defaultdict(set)
    input_dir = os.path.abspath(input_dir)
    base_depth = len(input_dir.rstrip(os.sep).split(os.sep))  # Глубина корневой директории

    for root, _, files in os.walk(input_dir):
        # Рассчитываем текущую глубину
        current_depth = len(root.rstrip(os.sep).split(os.sep)) - base_depth

        # Если глубина превышает max_depth, пропускаем директорию
        if max_depth is not None and current_depth > max_depth:
            continue

        for file in files:
            # Получаем относительный путь файла от input_dir
            rel_path = os.path.relpath(root, input_dir)
            if rel_path == '.':
                files_dict[file].add(file)  # Файл в корне директории
            else:
                files_dict[file].add(os.path.join(rel_path, file))  # Файл в поддиректории

    return files_dict

# Запуск из командной строки
if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python3 collect_files.py <input_dir> [max_depth]")
        sys.exit(1)

    input_dir = sys.argv[1]
    max_depth = None

    # Если max_depth передан, конвертируем в число
    if len(sys.argv) > 2:
        try:
            max_depth = int(sys.argv[2])
        except ValueError:
            print("Error: Max depth must be an integer")
            sys.exit(1)

    result = collect_files(input_dir, max_depth)
    print(dict(result))
