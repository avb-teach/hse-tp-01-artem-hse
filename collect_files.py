#!/usr/bin/env python3

import os
from collections import defaultdict
import shutil


def collect_files(input_dir, output_dir, max_depth=None):
    """
    Собирает файлы из указанной директории и её поддиректорий с учётом глубины.

    Args:
        input_dir (str): Входная директория.
        output_dir (str): Выходная директория.
        max_depth (int, optional): Максимальная глубина обхода.

    Returns:
        defaultdict: Словарь формата {имя файла: {относительные пути}}.
    """

    # Создаём выходную директорию
    os.makedirs(output_dir, exist_ok=True)

    # Хранение результатов в формате: имя файла -> пути файлов.
    result = defaultdict(set)
    abs_input_dir = os.path.abspath(input_dir)
    base_depth = abs_input_dir.rstrip(os.sep).count(os.sep)

    for root, _, files in os.walk(abs_input_dir):
        # Рассчитываем текущую глубину.
        rel_path = os.path.relpath(root, abs_input_dir)
        current_depth = root.rstrip(os.sep).count(os.sep) - base_depth

        # Если текущая глубина превышает max_depth, пропускаем директорию.
        if max_depth is not None and current_depth >= max_depth:
            continue

        for file in files:
            relative_file_path = os.path.join(rel_path, file)
            abs_file_path = os.path.join(root, file)

            # Копируем файл в выходную директорию, сохраняя структуру.
            dest_dir = os.path.join(output_dir, rel_path)
            os.makedirs(dest_dir, exist_ok=True)
            shutil.copy2(abs_file_path, os.path.join(dest_dir, file))

            # Добавляем результат в словарь.
            result[file].add(relative_file_path)

    return result


if __name__ == "__main__":
    import sys

    # Парсим аргументы командной строки.
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

    # Запускаем функцию.
    collect_files(input_dir, output_dir, max_depth)
