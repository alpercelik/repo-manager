#!/bin/bash

# Function to clean specific folders
clean_folders() {
    local dir="$1"
    
    echo "Cleaning build artifacts in: $dir"
    
    # Find and remove build folders
    find "$dir" -type d \( \
        -name "bin" -o \
        -name "obj" -o \
        -name "build" -o \
        -name "dist" -o \
        -name ".next" -o \
        -name "node_modules" \
    \) -exec rm -rf {} +
    
    echo "Cleaning completed!"
}

# Check if directory argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    echo "Example: $0 ./github-repos"
    exit 1
fi

# Check if directory exists
if [ ! -d "$1" ]; then
    echo "Error: Directory '$1' does not exist"
    exit 1
fi

# Execute cleaning
clean_folders "$1"