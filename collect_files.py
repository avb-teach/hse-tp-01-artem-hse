#!/usr/bin/env python3

import os
import sys
import shutil


def collect_files(input_dir, output_dir, max_depth=None):
    """
    Скопировать файлы из input_dir в output_dir с сохранением структуры директорий
    и учётом ограничения по глубине (max_depth).

    Args:
        input_dir (str): Входная директория.
        output_dir (str): Выходная директория.
        max_depth (int, optional): Максимальная глубина копирования. None = без ограничений.

    Returns:
        None
    """
    # Убедимся, что выходная директория существует
    os.makedirs(output_dir, exist_ok=True)

    # Рассчитываем базовую глубину (глубина корневой входной директории)
    base_depth = input_dir.rstrip(os.sep).count(os.sep)

    # Обходим все вложенные директории
    for root, dirs, files in os.walk(input_dir):
        # Текущая глубина директории
        current_depth = root.rstrip(os.sep).count(os.sep) - base_depth

        # Если текущая глубина превышает max_depth, исключаем каталоги
        if max_depth is not None and current_depth >= max_depth:
            dirs[:] = []  # Не заходим глубже
            continue

        # Вычисляем относительный путь текущей директории относительно input_dir
        relative_path = os.path.relpath(root, input_dir)
        if relative_path == ".":
            relative_path = ""  # Корень

        # Выходная директория для текущих файлов
        output_subdir = os.path.join(output_dir, relative_path)
        os.makedirs(output_subdir, exist_ok=True)

        # Копируем файлы
        for file in files:
            src_file = os.path.join(root, file)
            dest_file = os.path.join(output_subdir, file)
            shutil.copy2(src_file, dest_file)


if __name__ == "__main__":
    # Проверка аргументов командной строки
    if len(sys.argv) < 3:
        print("Usage: python3 collect_files.py <input_dir> <output_dir> [max_depth]")
        sys.exit(1)

    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    max_depth = None

    # Обработка аргумента max_depth
    if len(sys.argv) > 3:
        try:
            max_depth = int(sys.argv[3])
        except ValueError:
            print("Error: max_depth must be an integer")
            sys.exit(1)

    # Запуск функции
    collect_files(input_dir, output_dir, max_depth)
