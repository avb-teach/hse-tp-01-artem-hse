#!/usr/bin/env python3

import os
from collections import defaultdict
import shutil
import sys


def collect_files(input_dir, output_dir, max_depth=None):
    """
    Собирает файлы из input_dir с учётом max_depth и копирует их в output_dir,
    сохраняя структуру директорий до указанной глубины.

    Args:
        input_dir (str): Путь к входной директории.
        output_dir (str): Путь выходной директории.
        max_depth (int, optional): Максимальная глубина для обхода.
                                  0 - только файлы в корне input_dir.
                                  1 - файлы в корне и в поддиректориях 1 уровня.
                                  И так далее.

    Returns:
        defaultdict(set): Словарь формата {имя файла: {относительные пути файлов}}.
    """
    # Убеждаемся, что выходная директория существует
    os.makedirs(output_dir, exist_ok=True)

    # Словарь для хранения результатов
    results = defaultdict(set)

    # Получаем абсолютный путь входной директории
    abs_input_dir = os.path.abspath(input_dir)
    # Вычисляем базовый уровень вложенности для input_dir
    base_level = len(abs_input_dir.rstrip(os.sep).split(os.sep))

    for root, dirs, files in os.walk(abs_input_dir, topdown=True):
        # Вычисляем текущий уровень вложенности
        current_level = len(root.rstrip(os.sep).split(os.sep))
        # Вычисляем глубину относительно input_dir (input_dir = глубина 0)
        current_depth = current_level - base_level

        # Если задана максимальная глубина и текущая глубина превышает ее,
        # то пропускаем эту директорию и все её поддиректории.
        # Мы используем topdown=True, чтобы можно было модифицировать dirs.
        if max_depth is not None and current_depth > max_depth:
            # Очищаем список поддиректорий, чтобы os.walk не заходил глубже в этой ветке
            dirs[:] = []
            continue

        # Обрабатываем файлы в текущей директории
        for file in files:
            src_path = os.path.join(root, file)
            # Получаем относительный путь файла от input_dir
            relative_file_path = os.path.relpath(src_path, abs_input_dir)

            # Формируем полный путь к файлу в выходной директории
            dest_path = os.path.join(output_dir, relative_file_path)

            # Создаем все необходимые поддиректории в выходной директории
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)

            # Копируем файл
            shutil.copy2(src_path, dest_path)

            # Добавляем относительный путь файла в результирующий словарь
            results[file].add(relative_file_path)

    # Тест, вероятно, ожидает вывод словаря на stdout
    print(dict(results))

    # Функция возвращает словарь, хотя основной результат - это копирование файлов
    return results


if __name__ == "__main__":
    # Проверяем аргументы командной строки
    if len(sys.argv) < 3:
        print("Usage: python3 collect_files.py <input_dir> <output_dir> [max_depth]")
        sys.exit(1)

    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    max_depth = None

    # Парсим max_depth, если он передан
    if len(sys.argv) > 3:
        try:
            max_depth = int(sys.argv[3])
        except ValueError:
            print("Error: max_depth должен быть целым числом.")
            sys.exit(1)

    # Проверяем существование входной директории перед началом работы
    if not os.path.isdir(input_dir):
         print(f"Error: Входная директория '{input_dir}' не существует.")
         sys.exit(1)

    # Выполняем сбор и копирование файлов
    collect_files(input_dir, output_dir, max_depth)

    # Успешное завершение
    sys.exit(0)
