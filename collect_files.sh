#!/bin/bash

if [ "$#" -eq 4 ] && [ "$3" = "--max_depth" ]; then
    python3 collect_files.py "\$1" "\$2" "\$4"
else
    python3 collect_files.py "\$1" "$2"
fi
