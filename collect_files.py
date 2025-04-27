#!/usr/bin/env python3

import os
import sys
import shutil

def collect_files(input_dir, output_dir, max_depth=None):
    """
    Рекурсивно копирует файлы из input_dir в output_dir с учетом max_depth.
    """

    # Уровень вложенности input_dir
    base_depth = len(input_dir.rstrip('/').split('/'))

    # Копируем файлы
    for root, dirs, files in os.walk(input_dir):
        # Рассчитываем текущую глубину
        current_depth = len(root.rstrip('/').split('/')) - base_depth

        # Пропускаем директории, превышающие max_depth
        if max_depth is not None and current_depth >= max_depth:
            dirs[:] = []
            continue

        for file in files:
            # Полный путь к исходному файлу
            src_path = os.path.join(root, file)
            # Путь к файлу в выходной директории
            dst_path = os.path.join(output_dir, file)

            # Если файл с таким именем уже существует, добавляем суффикс
            counter = 1
            while os.path.exists(dst_path):
                name, ext = os.path.splitext(file)
                dst_path = os.path.join(output_dir, f"{name}_{counter}{ext}")
                counter += 1

            # Копируем файл
            shutil.copy2(src_path, dst_path)

if __name__ == "__main__":
    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    max_depth = int(sys.argv[3]) if len(sys.argv) > 3 else None

    # Создаем выходную директорию, если её нет
    os.makedirs(output_dir, exist_ok=True)

    collect_files(input_dir, output_dir, max_depth)
