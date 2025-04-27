#!/usr/bin/env python3
import os
import sys
import shutil
import argparse

def main():

    parser = argparse.ArgumentParser(description='Собирает файлы из входной директории в выходную.')
    parser.add_argument('input_dir', help='Входная директория')
    parser.add_argument('output_dir', help='Выходная директория')
    parser.add_argument('--max_depth', type=int, help='Максимальная глубина копирования')
    
    args = parser.parse_args()
    
    input_dir = args.input_dir
    output_dir = args.output_dir
    max_depth = args.max_depth
    
    os.makedirs(output_dir, exist_ok=True)
    
    base_depth = len(input_dir.rstrip('/').split('/'))
    
    for root, dirs, files in os.walk(input_dir):

        current_depth = len(root.rstrip('/').split('/')) - base_depth
        
        if max_depth is not None and current_depth > max_depth:
            dirs[:] = [] 
            continue
        
        if max_depth is not None:
            rel_path = os.path.relpath(root, input_dir)
            
            for file in files:
                src = os.path.join(root, file)
                
                if rel_path == '.':
                    dst = os.path.join(output_dir, file)
                else:
                    dst_dir = os.path.join(output_dir, rel_path)
                    os.makedirs(dst_dir, exist_ok=True)
                    dst = os.path.join(dst_dir, file)
                
                if os.path.exists(dst):
                    name, ext = os.path.splitext(file)
                    counter = 1
                    while os.path.exists(dst):
                        new_name = f'{name}{counter}{ext}'
                        if rel_path == '.':
                            dst = os.path.join(output_dir, new_name)
                        else:
                            dst = os.path.join(dst_dir, new_name)
                        counter += 1
                
                shutil.copy2(src, dst)
        else:
            for file in files:
                src = os.path.join(root, file)
                dst = os.path.join(output_dir, file)
                
                if os.path.exists(dst):
                    name, ext = os.path.splitext(file)
                    counter = 1
                    while os.path.exists(dst):
                        dst = os.path.join(output_dir, f'{name}{counter}{ext}')
                        counter += 1
                
                shutil.copy2(src, dst)

if __name__ == "__main__":
    main()