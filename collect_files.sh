import os
import shutil
import sys
from collections import defaultdict

def copy_files(input_dir, output_dir, max_depth=-1):

   
    file_counts = defaultdict(int)
    
    def unique_filename(filename):

        base_name, ext = os.path.splitext(filename)
        count = file_counts[filename]
        file_counts[filename] += 1
        
        if count == 0:
            return filename
        return f"{base_name}{count}{ext}"
    
    def process_directory(current_dir, current_depth=0):

        if max_depth != -1 and current_depth > max_depth:
            rel_path = os.path.relpath(current_dir, input_dir)
            dest_path = os.path.join(output_dir, rel_path)

            if not os.path.exists(dest_path):
                shutil.copytree(current_dir, dest_path)
            return
            
        for item in os.listdir(current_dir):
            full_path = os.path.join(current_dir, item)
            
            if os.path.isfile(full_path):

                if max_depth != -1:
            
                    rel_path = os.path.relpath(current_dir, input_dir)
                    dest_dir = os.path.join(output_dir, rel_path)
                    os.makedirs(dest_dir, exist_ok=True)
                    
                    unique_name = unique_filename(item)
                    dest_path = os.path.join(dest_dir, unique_name)

                else:
                  
                    unique_name = unique_filename(item)
                    dest_path = os.path.join(output_dir, unique_name)
                
                shutil.copy2(full_path, dest_path)
            
            elif os.path.isdir(full_path):
                if max_depth == -1 or current_depth < max_depth:
                    process_directory(full_path, current_depth + 1)
                else:
                   
                    rel_path = os.path.relpath(full_path, input_dir)
                    dest_path = os.path.join(output_dir, rel_path)
                    if not os.path.exists(dest_path):
                        shutil.copytree(full_path, dest_path)

def main():

    if len(sys.argv) < 3:
        sys.exit(1)
    
    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    max_depth = -1
 
    if len(sys.argv) == 5 and sys.argv[3] == "--max_depth":
        try:
            max_depth = int(sys.argv[4])
        except ValueError:
            print("Ошибка: max_depth должен быть целым числом")
            sys.exit(1)
    
    if not os.path.isdir(input_dir):
        print(f"Ошибка: Директория {input_dir} не существует")
        sys.exit(1)
    

    os.makedirs(output_dir, exist_ok=True)

    copy_files(input_dir, output_dir, max_depth)

if __name__ == "__main__":
    main()
