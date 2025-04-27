#!/usr/bin/env python3

import os
from collections import defaultdict


def collect_files(input_dir, output_dir, max_depth=None):
    """
    Сбор файлов из input_dir в output_dir с учётом max_depth.
    Скрипт сохраняет структуру директорий и обрабатывает глубину корректно.

    Args:
        input_dir (str): Путь к входной директории.
        output_dir (str): Путь к выходной директории.
        max_depth (int, optional): Максимальная глубина для обхода файлов.

    Returns:
        defaultdict: {имя файла: {пути к файлам}}
    """

    # Создаем выходную директорию
    os.makedirs(output_dir, exist_ok=True)

    result = defaultdict(set)
    abs_input_dir = os.path.abspath(input_dir)
    base_depth = abs_input_dir.rstrip(os.sep).count(os.sep)

    for root, _, files in os.walk(abs_input_dir):
        # Рассчитываем текущую глубину директории
        current_depth = root.rstrip(os.sep).count(os.sep) - base_depth

        # Пропуск директорий, если превышена максимальная глубина
        if max_depth is not None and current_depth >= max_depth:
            continue

        # Обработка каждого файла
        for file in files:
            # Путь к исходному файлу
            src_path = os.path.join(root, file)
            # Относительный путь от корня
            rel_path = os.path.relpath(src_path, abs_input_dir)
            # Путь в выходной директории
            dest_path = os.path.join(output_dir, rel_path)

            # Создание вложенных директорий
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)

            # Копирование файла
            with open(src_path, "rb") as src_file, open(dest_path, "wb") as dest_file:
                dest_file.write(src_file.read())

            # Добавляем путь в результат
            result[file].add(rel_path)

    return result


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

    collect_files(input_dir, output_dir, max_depth)
