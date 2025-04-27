#!/usr/bin/env python3

import os
from collections import defaultdict
import shutil


def collect_files(input_dir, output_dir, max_depth=None):
    """
    Сбор файлов из содержащей директории в output_dir с учётом глубины.

    Args:
        input_dir (str): Входная директория.
        output_dir (str): Директория назначения.
        max_depth (int, optional): Уровень глубины (None для неограниченного обхода).

    Returns:
        defaultdict: {имя файла: {относительные пути}}
    """
    os.makedirs(output_dir, exist_ok=True)
    file_map = defaultdict(set)
    abs_input_dir = os.path.abspath(input_dir)
    base_depth = abs_input_dir.rstrip(os.sep).count(os.sep)

    for root, _, files in os.walk(abs_input_dir):
        # Вычисляем текущую глубину директории
        current_depth = root.rstrip(os.sep).count(os.sep) - base_depth
        if max_depth is not None and current_depth >= max_depth:
            continue

        for file in files:
            relative_path = os.path.relpath(root, abs_input_dir)
            if relative_path == ".":
                relative_path = ""  # Для файлов в корне директории

            src_path = os.path.join(root, file)
            dest_path = os.path.join(output_dir, relative_path, file)

            # Создаём недостающие папки в output_dir
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)

            # Копируем файл
            shutil.copy2(src_path, dest_path)

            # Добавляем файл в результирующий словарь
            rel_file_path = os.path.join(relative_path, file) if relative_path else file
            file_map[file].add(rel_file_path)

    return file_map


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 3:
        print("Usage: python3 collect_files.py <input_dir> <output_dir> [max_depth]")
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

    result = collect_files(input_dir, output_dir, max_depth)
    print(dict(result))
