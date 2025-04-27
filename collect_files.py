#!/usr/bin/env python3

import os
import sys
import shutil
from collections import defaultdict

def collect_files(input_dir, output_dir, max_depth=None):
    os.makedirs(output_dir, exist_ok=True)
    base_depth = len(input_dir.rstrip('/').split('/'))
    results = defaultdict(set)
    
    for root, dirs, files in os.walk(input_dir):
        current_depth = len(root.rstrip('/').split('/')) - base_depth
        if max_depth is not None and current_depth > max_depth:
            continue
            
        for file in files:
            src_path = os.path.join(root, file)
            rel_path = os.path.relpath(src_path, input_dir)
            dst_path = os.path.join(output_dir, rel_path)
            
            os.makedirs(os.path.dirname(dst_path), exist_ok=True)
            shutil.copy2(src_path, dst_path)
            results[file].add(rel_path)
    
    print(dict(results))
    return results

if __name__ == "__main__":
    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    max_depth = int(sys.argv[3]) if len(sys.argv) > 3 else None
    
    collect_files(input_dir, output_dir, max_depth)
