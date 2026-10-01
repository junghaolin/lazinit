#!/bin/bash
# This script should be sourced, not executed.

run() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: run <problem_number> <language>"
        echo "Example: run 0001 go"
        return 1
    fi

    local problem_num=$1
    local lang=$2
    local problem_dir_glob

    # Find the directory in problems/new that starts with the problem number
    problem_dir_glob=(problems/new/${problem_num}.*/)
    
    # Check if any directory matched the glob
    if [ ! -d "${problem_dir_glob[0]}" ]; then
        echo "Error: Problem directory for number '$problem_num' not found in problems/new/."
        return 1
    fi
    
    # Use the first match
    local problem_dir_path=${problem_dir_glob[0]}
    local target_path="${problem_dir_path}${lang}"

    if [ ! -d "$target_path" ]; then
        echo "Error: Language '$lang' not found for problem '$problem_num'."
        echo "Searched path: $target_path"
        return 1
    fi

    # Execute the actual run script, assuming this function is called from project root
    scripts/run.sh "$target_path"
}
