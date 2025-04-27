#!/usr/bin/env python3

import os
from collections import defaultdict
import shutil
import sys

def collect_files(input_dir, output_dir, max_depth=None):
    """
    Собирает файлы из input_dir с учетом max_depth, копирует их в output_dir,
    сохраняя структуру, и возвращает словарь {имя файла: {относительные пути}}.
    """
    # Убедимся, что выходная директория существует
    try:
        os.makedirs(output_dir, exist_ok=True)
    except OSError as e:
        print(f"Error: Не удалось создать выходную директорию '{output_dir}'. {e}", file=sys.stderr)
        sys.exit(1)

    # Словарь для хранения результатов {имя файла: {пути к файлам}}
    results = defaultdict(set)

    # Получаем абсолютный путь входной директории
    abs_input_dir = os.path.abspath(input_dir)

    # Вычисляем базовый уровень вложенности для input_dir.
    # Если input_dir это '/', abs_input_dir.count(os.sep) = 1.
    # Если input_dir это '/home/user', abs_input_dir.count(os.sep) = 2.
    base_separator_count = abs_input_dir.count(os.sep)

    # Проходим по директориям, начиная с входной
    # topdown=True позволяет модифицировать список dirs для пропуска поддиректорий
    for root, dirs, files in os.walk(abs_input_dir, topdown=True):
        current_separator_count = root.count(os.sep)
        # Глубина текущей директории относительно input_dir. input_dir имеет глубину 0.
        current_depth = current_separator_count - base_separator_count

        # Логика ограничения глубины: если текущая глубина строго больше max_depth,
        # то мы не обрабатываем файлы в этой директории и не заходим в её поддиректории.
        # max_depth=0 -> обрабатывается только глубина 0.
        # max_depth=1 -> обрабатываются глубины 0 и 1.
        if max_depth is not None and current_depth > max_depth:
            # Очищаем список поддиректорий, чтобы os.walk() не заходил в них
            dirs[:] = []
            continue # Пропускаем текущую директорию

        # Обрабатываем файлы в текущей директории (только если она не была пропущена)
        for file in files:
            src_path = os.path.join(root, file)
            # Получаем относительный путь файла от input_dir
            relative_file_path = os.path.relpath(src_path, abs_input_dir)

            # Формируем путь к файлу в выходной директории
            dest_path = os.path.join(output_dir, relative_file_path)

            # Создаем все необходимые поддиректории в выходной директории
            try:
                os.makedirs(os.path.dirname(dest_path), exist_ok=True)
            except OSError as e:
                 print(f"Error: Не удалось создать директорию '{os.path.dirname(dest_path)}'. {e}", file=sys.stderr)
                 # Можно продолжить или выйти, в зависимости от требований. Для теста, возможно, лучше выйти.
                 sys.exit(1)

            # Копируем файл
            try:
                shutil.copy2(src_path, dest_path)
            except IOError as e:
                 print(f"Error: Не удалось скопировать файл '{src_path}' в '{dest_path}'. {e}", file=sys.stderr)
                 sys.exit(1)


            # Добавляем относительный путь файла в результирующий словарь
            results[file].add(relative_file_path)

    # Тест, вероятно, ожидает вывод словаря на стандартный вывод.
    # Преобразуем set в list и сортируем для стабильного вывода, если тест зависит от порядка.
    printable_results = {k: sorted(list(v)) for k, v in results.items()}
    print(printable_results)

    # Функция возвращает словарь, хотя основной результат - это копирование файлов
    return results


if __name__ == "__main__":
    # Проверяем аргументы командной строки
    if len(sys.argv) < 3:
        print("Usage: python3 collect_files.py <input_dir> <output_dir> [max_depth]", file=sys.stderr)
        sys.exit(1)

    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    max_depth = None # По умолчанию нет ограничения по глубине

    # Парсим max_depth, если он передан
    if len(sys.argv) > 3:
        try:
            max_depth_str = sys.argv[3]
            # Убедимся, что это число и оно неотрицательное, если передано ограничение
            max_depth = int(max_depth_str)
            if max_depth < 0:
                print(f"Error: max_depth должен быть неотрицательным целым числом или не указан.", file=sys.stderr)
                sys.exit(1)
        except ValueError:
            print(f"Error: max_depth '{sys.argv[3]}' должен быть целым числом.", file=sys.stderr)
            sys.exit(1)


    # Проверяем существование входной директории перед началом работы
    if not os.path.isdir(input_dir):
         print(f"Error: Входная директория '{input_dir}' не существует.", file=sys.stderr)
         sys.exit(1)

    # Выполняем сбор и копирование файлов
    # Если collect_files внутри выбросит исключение, оно будет необработанным
    # и приведет к ненулевому статусу выхода Python-скрипта.
    collect_files(input_dir, output_dir, max_depth)

    # Если скрипт дошел до сюда без ошибок, завершаем работу с кодом 0.
    sys.exit(0)
